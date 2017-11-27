package com.raidandfade.json;


#if java
@:classCode("public static String[] char2string = new String[Character.MAX_VALUE];
            static{
                for (char x = Character.MIN_VALUE; x < Character.MAX_VALUE; x++) {
                    char2string[x] = Character.toString(x);
                }
            }
")
#end

class StringUtils{

    public static function substr(s:String,i:Int,f:Null<Int>=null):String{
        #if java
        untyped __java__('
            String res = "";
        
            char[] st = {0}.toCharArray();

            for (int x = {1}; x < (int)({2}==null?st.length:{2}); x++) {
                res+=char2string[st[x]];
            }
        ',s,i,f);
        untyped return res;
        #else
            return f==null?s.substr(i):s.substr(i,f-i);
        #end
    }

    public static function charAt(s:String,i:Int):String{
        #if java
            untyped __java__('
                String res = char2string[{0}.charAt({1})];
            ',s,i);
            untyped return res;
        #else
            return s.charAt(i);
        #end
    }

    public static function codeAt(s:String,i):Int{
        #if java
            untyped __java__('
                int res = {0}.charAt({1});
            ',s,i);
            untyped return res;
        #else
        return StringTools.fastCodeAt(s,i);
        #end
    }
}