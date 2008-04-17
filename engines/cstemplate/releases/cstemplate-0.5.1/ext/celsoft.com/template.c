// Copyright (c) 2004 Sean O'Dell



#include <ruby.h>



// GLOBALS

// module and class type values

static VALUE template_module = Qnil;
static VALUE document_class = Qnil;

typedef volatile VALUE SVALUE;

//----------------------------------------------------------------------



// TRACE MACROS

// uncomment this to print debugging messages
//~ #define PRINT_TRACING

#ifdef PRINT_TRACING

  #define TRACE_PRINT()fprintf(stderr, "TRACE: %s, %s, line %d\n", __FUNCTION__, __FILE__, __LINE__)

  #include <sys/resource.h>

  // prints the status of various resource limits
  void trace_rlimit_print(int resource, char* resource_name)
  {
    struct rlimit rl;
    if(!getrlimit(resource, &rl))
      fprintf(stderr, "RLIMIT %s: %u of %u max\n", resource_name, rl.rlim_cur, rl.rlim_max);
  }

  #define TRACE_RLIMIT_PRINT(resource)trace_rlimit_print(resource, #resource)

#else

  #define TRACE_PRINT()
  #define TRACE_RLIMIT_PRINT(resource)

#endif // PRINT_TRACING

//----------------------------------------------------------------------






int ID_BINDING;
int ID_EACH;
int ID_EVAL;
int ID_INDEX;
int ID_KEYS;
int ID_NEW;
int ID_NEXT;
int ID_SLICE;
int ID_SLICE_ME;
int ID_SORT;
int ID_SPLIT;
int ID_TO_I;
int ID_TO_S;

VALUE STR_HASH;
VALUE STR_NEWLINE;
VALUE STR_SLASH;

VALUE REGEX_LINE;
VALUE REGEX_MACRO_END;
VALUE REGEX_MACRO_START_BEG;
VALUE REGEX_MACRO_START_MID;






void gsub_escape(char *value)
{
  char* head = value;
  
  while (value && *value)
  {
    if (*value == '\\' && value[1] == '$' && value[2] == '{')
      value++;
    *head = *value;
    
    if (*value)
    {
      head++;
      value++;
    }
  }
  
  *head = '\0';
}


char* template_parse_literal(char ** str_value)
{
  char* head = *str_value;
  char* value = head;
  char last_ch = 0;
  
  while (head && *head)
  {
    if (*head == '$' && head[1] == '{' && last_ch != '\\')
    {
      *head = '\0';
      *str_value = &head[2];
      gsub_escape(value);
      return value;
    }
    
    last_ch = *head;
    head++;
  }
  
  *str_value = head;
  gsub_escape(value);
  return value;
}

VALUE template_parse_macro(char ** str_value)
{
  char* head = *str_value;
  char* value = head;
  char last_ch = 0;
  SVALUE macro = Qnil;
  
  while (head && *head)
  {
    if (*head == '}' && last_ch != '\\')
    {
      *head = '\0';
      *str_value = &head[1];
      gsub_escape(value);
      
      macro = rb_ary_new();
      
      head = value;
      
      while (*head == ' ')
        head++;
      while (*head && *head != ' ')
        head++;
      last_ch = *head;
      *head = '\0';
      if (!*value) return Qnil;
      rb_ary_push(macro, rb_str_new2(value));
      if (last_ch)
        head++;
      value = head;
      if (*value)
        rb_ary_push(macro, rb_str_new2(value));
      
      return macro;
    }
    
    last_ch = *head;
    head++;
  }
  
  return Qnil;
}

VALUE template_parse(VALUE tree, VALUE value)
{
  char * org_str_value = NULL,
    * str_value = NULL,
    * literal = NULL;
  SVALUE macro = Qnil;

  if (value == Qnil) return Qnil;
  rb_check_type(value, T_STRING);
  
  org_str_value = str_value = malloc(RSTRING(value)->len + 1);
  strncpy(str_value, RSTRING(value)->ptr, RSTRING(value)->len);
  str_value[RSTRING(value)->len] = '\0';
  
  while (str_value && *str_value)
  {
    literal = template_parse_literal(&str_value);
    if (literal && *literal)
      rb_ary_push(tree, rb_str_new2(literal));
      
    macro = template_parse_macro(&str_value);
    if (macro != Qnil && RARRAY(macro)->len > 0)
      rb_ary_push(tree, macro);
    if (macro == Qnil)
      break;
  }
  
  literal = template_parse_literal(&str_value);
  if (literal && *literal)
    rb_ary_push(tree, rb_str_new2(literal));
    
  free(org_str_value);
  
  return tree;
}





char isnum(char * value)
{
  if (!value)
    return 0;
  while (*value)
  {
    if (*value < '0' || *value > '9')
      return 0;
    value++;
  }
  return 1;
}


VALUE get_node_context(VALUE context, char * path)
{
  SVALUE parent = Qnil;
  
  if (!path) return Qnil;
  
  while (*path == ' ')
    path++;

  parent = context;
  
  while (*path)
  {
    SVALUE node = Qnil;
    char * name = path,
      * head = name;
    char last_ch = 0;
    
    while (*head && *head != '/')
      head++;
    if (*head)
      path = &head[1];
    else
      path = head;
    *head = '\0';
    
    head = name;
    
    while (*head && *head != '#')
      head++;
    last_ch = *head;
    *head = '\0';
    if (last_ch)
      head++;
    
    if (!*name || *name == '.')
      node = parent;
    else
    {
      if (rb_type(parent) == T_HASH)
        node = rb_hash_aref(parent, rb_str_new2(name));
    }
    
    if (node == Qnil) return Qnil;
    
    while (*head && last_ch == '#')
    {
      char * id = head;
      
      if (rb_type(node) != T_ARRAY)
        return Qnil;
        
      while (*head && *head != '#')
        head++;
      last_ch = *head;
      *head = '\0';
      if (last_ch)
        head++;
        
      if (!*id || !isnum(id))
        return Qnil;
        
      node = rb_ary_entry(node, atoi(id));
      if (node == Qnil) return Qnil;
    }
    
    parent = node;
  } 
  
  return parent;
}

VALUE get_node_root(VALUE data, VALUE context, VALUE path)
{
  char * str_path = NULL,
    * str_path_copy = NULL;
  SVALUE result = Qnil;
  
  if (data == Qnil || context == Qnil || path == Qnil) return Qnil;
  
  rb_check_type(path, T_STRING);
  
  str_path = RSTRING(path)->ptr;
  
  if (*str_path == '/')
  {
    if (!str_path[1])
      return data;
    else
    {
      str_path++;
      context = data;
    }
  }
  
  str_path_copy = malloc(RSTRING(path)->len + 1);
  strcpy(str_path_copy, str_path);

  if (context == Qnil) return Qnil;
  
  result = get_node_context(context, str_path_copy);
  
  free(str_path_copy);
  
  return result;
}






VALUE document_initialize(VALUE self)
{
  rb_iv_set(self, "@data", Qnil);
  rb_iv_set(self, "@context", Qnil);
  rb_iv_set(self, "@tree", Qnil);

  return self;
}



VALUE document_data(VALUE self)
{
  return rb_iv_get(self, "@data");
}

VALUE document_data_eq(VALUE self, VALUE data)
{
  return rb_iv_set(self, "@data", data);
}

VALUE document_context(VALUE self)
{
  return rb_iv_get(self, "@context");
}

VALUE document_context_eq(VALUE self, VALUE context)
{
  return rb_iv_set(self, "@context", context);
}

VALUE document_tree(VALUE self)
{
  return rb_iv_get(self, "@tree");
}

VALUE document_tree_eq(VALUE self, VALUE tree)
{
  return rb_iv_set(self, "@tree", tree);
}






VALUE document_load(VALUE self, VALUE input)
{
  SVALUE tree = rb_ary_new();
  int index = 0;
  
  if (rb_type(input) == T_STRING)
  {
    SVALUE line = Qnil;
    SVALUE input_ary = rb_ary_new();
    
    do
    {
      line = rb_funcall(input, ID_SLICE_ME, 1, REGEX_LINE);
      if (line != Qnil)
        rb_ary_push(input_ary, line);
    } while( line != Qnil);
    
    if (RSTRING(input)->len > 0)
      rb_ary_push(input_ary, input);
    
    input = input_ary;
  }
  
  rb_check_type(input, T_ARRAY);
  
  for (index = 0 ; index < RARRAY(input)->len ; index++)
  {
    SVALUE line = RARRAY(input)->ptr[index];
    
    tree = template_parse(tree, line);
  }
  
  return rb_iv_set(self, "@tree", tree);
}



void skip_to_end_iteration(int *index, VALUE tree)
{
  int block_level = 1;
  int length = RARRAY(tree)->len;
  
  (*index)--;
  while (*index < length && block_level > 0)
  {
    (*index)++;
    SVALUE node = RARRAY(tree)->ptr[*index];
    
    if (rb_type(node) == T_ARRAY)
    {
      char *macro_name = NULL;
      if (RARRAY(node)->len < 1)
        continue;
        
      macro_name = RSTRING(RARRAY(node)->ptr[0])->ptr;
      
      if (strcmp(macro_name, "end") == 0)
        block_level--;
      else if (strcmp(macro_name, "with") == 0 || strcmp(macro_name, "each") == 0 || strcmp(macro_name, "if") == 0)
        block_level++;
    }
  }
}

char skip_to_else_iteration(int *index, VALUE tree)
{
  int block_level = 1;
  int length = RARRAY(tree)->len;
  
  (*index)--;
  while (*index < length && block_level > 0)
  {
    (*index)++;
    SVALUE node = RARRAY(tree)->ptr[*index];
    
    if (rb_type(node) == T_ARRAY)
    {
      char *macro_name = NULL;
      if (RARRAY(node)->len < 1)
        continue;
        
      macro_name = RSTRING(RARRAY(node)->ptr[0])->ptr;
      
      if (strcmp(macro_name, "end") == 0)
        block_level--;
      else if (block_level == 1 && strcmp(macro_name, "else") == 0)
        return 1;
      else if (strcmp(macro_name, "with") == 0 || strcmp(macro_name, "each") == 0 || strcmp(macro_name, "if") == 0)
        block_level++;
    }
  }
  
  return 0;
}

VALUE eval_binding_protected(VALUE args)
{
  VALUE binding = rb_ary_shift(args);
  VALUE eval = rb_ary_shift(args);
  
  return rb_funcall(rb_mKernel, ID_EVAL, 2, eval, binding);
}

VALUE eval_binding(VALUE binding_object, VALUE eval)
{
  VALUE args = Qnil,
    result = Qnil;
  int error = 0;
  
  args = rb_ary_new();
  rb_ary_push(args, rb_funcall(binding_object, ID_BINDING, 0));
  rb_ary_push(args, eval);
  
  result = rb_protect(eval_binding_protected, args, &error);
  
  return error ? Qnil : result;
}

VALUE output_iteration(int *index, VALUE tree, VALUE data, VALUE context)
{
  SVALUE output = rb_str_new2("");
  int length = 0;
  
  rb_check_type(tree, T_ARRAY);
  
  length = RARRAY(tree)->len;

  while (*index < length)
  {
    SVALUE node = RARRAY(tree)->ptr[*index];
    
    if (rb_type(node) == T_STRING)
      rb_str_concat(output, node);
    else if (rb_type(node) == T_ARRAY)
    {
      char *macro_name = NULL;
      if (RARRAY(node)->len < 1)
        goto next_index;
        
      macro_name = RSTRING(RARRAY(node)->ptr[0])->ptr;
      if (strcmp(macro_name, "var") == 0)
      {
        SVALUE key = Qnil,
          value = Qnil;
        
        if (RARRAY(node)->len < 2)
          goto next_index;
          
        key = RARRAY(node)->ptr[1];
        if (key == Qnil || RSTRING(key)->len == 0)
          goto next_index;
          
        value = get_node_root(data, context, key);
        if (value != Qnil)
          value = rb_funcall(value, ID_TO_S, 0);
        if (value != Qnil && RSTRING(value)->len > 0)
          rb_str_concat(output, value);
      }
      else if (strcmp(macro_name, "each") == 0)
      {
        SVALUE key = Qnil,
          each_node = Qnil;
        int old_index = 0;
      
        if (RARRAY(node)->len < 2)
          goto next_index;
          
        key = RARRAY(node)->ptr[1];
        if (key == Qnil || RSTRING(key)->len == 0)
          goto next_index;
          
        each_node = get_node_root(data, context, key);
        
        (*index)++;
        old_index = *index;
        
        if (rb_type(each_node) == T_STRING && RSTRING(each_node)->len > 0)
          each_node = rb_funcall(each_node, ID_SPLIT, 1, STR_NEWLINE);
        
        if (rb_type(each_node) == T_ARRAY || rb_type(each_node) == T_HASH)
        {
          SVALUE child_node = Qnil;
          int node_index = 0;
          
          if (rb_type(each_node) == T_HASH)
          {
            SVALUE keys = rb_funcall(each_node, ID_KEYS, 0);
            SVALUE pairs = rb_ary_new();
            
            if (keys == Qnil)
            {
              skip_to_end_iteration(index, tree);
              goto next_index;
            }
            
            keys = rb_funcall(keys, ID_SORT, 0);
            
            for (node_index = 0 ; node_index < RARRAY(keys)->len ; node_index++)
            {
              if (RARRAY(keys)->ptr[node_index] != Qnil)
              {
                SVALUE pair = rb_ary_new();
                
                rb_ary_push(pair, RARRAY(keys)->ptr[node_index]);
                rb_ary_push(pair, rb_hash_aref(each_node, RARRAY(keys)->ptr[node_index]));
                rb_ary_push(pairs, pair);
              }
            }
            
            each_node = pairs;
          }
          
          for (node_index = 0 ; node_index < RARRAY(each_node)->len ; node_index++)
          {
            child_node = RARRAY(each_node)->ptr[node_index];
            *index = old_index;
            rb_str_concat(output, output_iteration(index, tree, data, child_node));
          }
        }
        else if (each_node != Qnil && rb_type(each_node) != T_STRING)
        {
          rb_str_concat(output, output_iteration(index, tree, data, each_node));
        }
        else // skip to next matching end macro
          skip_to_end_iteration(index, tree);
      }
      else if (strcmp(macro_name, "with") == 0)
      {
        SVALUE key = Qnil,
          with_node = Qnil;
      
        if (RARRAY(node)->len < 2)
          goto next_index;
          
        key = RARRAY(node)->ptr[1];
        if (key == Qnil || RSTRING(key)->len == 0)
          goto next_index;
          
        with_node = get_node_root(data, context, key);
        
        (*index)++;
        
        if (with_node != Qnil)
          rb_str_concat(output, output_iteration(index, tree, data, with_node));
        else // skip to next matching end macro
          skip_to_end_iteration(index, tree);
      }
      else if (strcmp(macro_name, "if") == 0)
      {
        SVALUE key = Qnil,
          if_node = Qnil;
      
        if (RARRAY(node)->len < 2)
          goto next_index;
          
        key = RARRAY(node)->ptr[1];
        if (key == Qnil || RSTRING(key)->len == 0)
          goto next_index;
          
        if_node = get_node_root(data, context, key);
        
        (*index)++;
        
        if ((rb_type(if_node) == T_STRING && RSTRING(if_node)->len > 0) || 
          (if_node != Qnil && rb_type(if_node) != T_STRING))
          rb_str_concat(output, output_iteration(index, tree, data, context));
        else
        {
          if (skip_to_else_iteration(index, tree))
          {
            (*index)++;
            rb_str_concat(output, output_iteration(index, tree, data, context));
          }
        }
      }
      else if (strcmp(macro_name, "else") == 0)
      {
        skip_to_end_iteration(index, tree);
        continue;
      }
      else if (strcmp(macro_name, "end") == 0)
      {
        return output;
      }
      else if (strcmp(macro_name, "include") == 0)
      {
        FILE* include_file = NULL;
        char buffer[1024];
        
        memset(&buffer, sizeof(buffer), 0);
      
        if (RARRAY(node)->len < 2)
          goto next_index;
          
        include_file = fopen(RSTRING(RARRAY(node)->ptr[1])->ptr, "rb");
        if (include_file)
        {
          while (!feof(include_file))
          {
            int read = fread(buffer, 1, sizeof(buffer) - 1, include_file);
            if (read > 0)
            {
              buffer[read] = '\0';
              rb_str_concat(output, rb_str_new2(buffer));
            }
          }
        }
      }
      else if (strcmp(macro_name, "eval") == 0)
      {
        SVALUE eval = Qnil,
          binding_object = Qnil,
          result = Qnil;
      
        if (RARRAY(node)->len < 2)
          goto next_index;
          
        eval = RARRAY(node)->ptr[1];
        if (eval == Qnil || RSTRING(eval)->len == 0)
          goto next_index;
        
        binding_object = rb_class_new_instance(0, NULL, rb_cObject);
        
        rb_iv_set(binding_object, "@tree", tree);
        rb_iv_set(binding_object, "@data", data);
        rb_iv_set(binding_object, "@context", context);
        
        result = eval_binding(binding_object, eval);
        
        if (rb_type(result) == T_STRING)
          rb_str_concat(output, result);
        else if (rb_type(result) == T_ARRAY)
        {
          int index = 0;
          
          for (index = 0 ; index < RARRAY(result)->len ; index++)
          {
            if (rb_type(RARRAY(result)->ptr[index]) == T_STRING)
              rb_str_concat(output, RARRAY(result)->ptr[index]);
          }
        }
      }
    }
    
next_index:
    (*index)++;
    continue;
  }
  
  return output;
}
  
VALUE document_output(VALUE self)
{
  int index = 0;
  SVALUE data = rb_iv_get(self, "@data");
  SVALUE tree = rb_iv_get(self, "@tree");
  return output_iteration(&index, tree, data, data);
}



VALUE document_resolve(VALUE self, VALUE path)
{
  SVALUE data = rb_iv_get(self, "@data");
  
  return get_node_root(data, data, path);
}









void Init_template()
{
  ID_BINDING = rb_intern("binding");
  ID_EACH = rb_intern("each");
  ID_EVAL = rb_intern("eval");
  ID_INDEX = rb_intern("index");
  ID_KEYS = rb_intern("keys");
  ID_NEW = rb_intern("new");
  ID_NEXT = rb_intern("next");
  ID_SLICE = rb_intern("slice");
  ID_SLICE_ME = rb_intern("slice!");
  ID_SORT = rb_intern("sort");
  ID_SPLIT = rb_intern("split");
  ID_TO_I = rb_intern("to_i");
  ID_TO_S = rb_intern("to_s");
  
  STR_HASH = rb_str_new2("#");
  rb_global_variable(&STR_HASH);
  STR_NEWLINE = rb_str_new2("\n");
  rb_global_variable(&STR_NEWLINE);
  STR_SLASH = rb_str_new2("/");
  rb_global_variable(&STR_SLASH);
  
  REGEX_LINE = rb_funcall(rb_cRegexp, ID_NEW, 1, rb_str_new2("^.*\\n"));
  rb_global_variable(&REGEX_LINE);

  template_module = rb_define_module("Template");
  
  document_class = rb_define_class_under(template_module, "Document", rb_cObject);
  
  rb_define_method(document_class, "initialize", document_initialize, 0);
  rb_define_method(document_class, "data", document_data, 0);
  rb_define_method(document_class, "data=", document_data_eq, 1);
  rb_define_method(document_class, "tree", document_tree, 0);
  rb_define_method(document_class, "tree=", document_tree_eq, 1);
  rb_define_method(document_class, "load", document_load, 1);
  rb_define_method(document_class, "output", document_output, 0);
  rb_define_method(document_class, "resolve", document_resolve, 1);
}
