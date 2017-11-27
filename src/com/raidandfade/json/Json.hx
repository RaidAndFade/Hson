package com.raidandfade.json;

import haxe.Timer;
import haxe.PosInfos;

class Json{

    public static var test = '[{
  "id": 1,
  "first_name": "Page",
  "last_name": "Munnis",
  "email": "pmunnis0@smh.com.au",
  "gender": "Male",
  "ip_address": "27.129.237.232",
  "favnum": 8610
}, {
  "id": 2,
  "first_name": "Timothea",
  "last_name": "Runnacles",
  "email": "trunnacles1@nifty.com",
  "gender": "Female",
  "ip_address": "118.46.54.173",
  "favnum": 5597
}, {
  "id": 3,
  "first_name": "Daron",
  "last_name": "Yakunin",
  "email": "dyakunin2@xinhuanet.com",
  "gender": "Male",
  "ip_address": "6.185.84.204",
  "favnum": 9873
}, {
  "id": 4,
  "first_name": "Marcel",
  "last_name": "Vayne",
  "email": "mvayne3@ucla.edu",
  "gender": "Male",
  "ip_address": "37.133.100.18",
  "favnum": 7355
}, {
  "id": 5,
  "first_name": "Crystie",
  "last_name": "Andersen",
  "email": "candersen4@xinhuanet.com",
  "gender": "Female",
  "ip_address": "17.58.104.47",
  "favnum": 5569
}]';

    public static function main(){
        var p1 = haxe.Json.parse(test);
        var p2 = parse(test);
        trace(p1);
        trace(p2);      
        var s1 = measure(function(){
            for(i in 0...2500)
                haxe.Json.parse(test);
        });
        var s2 = measure(function(){
            for(i in 0...2500)
                parse(test);
        });

        trace(p1==p2);
        trace(s1+"s");
        trace(s2+"s");
        trace(Math.round((s2/s1)*100)+"% the speed");
    }

    static function measure(f,?pos : PosInfos){
        var t0 = Timer.stamp();
		f();
		return (Timer.stamp() - t0);
    }

    private static var i = 0;

    static function checkEquals(s,s2){
        return StringUtils.substr(s,i,s2.length)==s2;
    }

    public static function parse(s:String,fresh:Bool=true):Dynamic{
        if(fresh)i=0;
        var c = StringUtils.codeAt(s,i);
        while(c==' '.code||c=="\n".code||c=='\r'.code||c=="\t".code){
            i++;
            c = StringUtils.codeAt(s,i);
        }
        c = StringUtils.codeAt(s,i++);//s.charAt(i++);
        if(c=='"'.code){
            return _parseString(s);
        }
        if(c=='['.code){
            return _parseArray(s);
        }
        if(c=='{'.code){
            return _parseObject(s);
        }
        i--;
        if(c=='-'.code||c=='0'.code||c=='1'.code||c=='2'.code||c=='3'.code||c=='4'.code||c=='5'.code||c=='6'.code||c=='7'.code||c=='8'.code||c=='9'.code){
            return _parseNumber(s);
        }
        if(checkEquals(s,"true")){
            i+=4;
            return true;
        }
        if(checkEquals(s,"false")){
            i+=5;
            return false;
        }
        if(checkEquals(s,"null")){
            i+=4;
            return null;
        }
        throw "Malformed Json @"+(i-1)+". Unexpected '"+c+"'";
    }

    static function _parseObject(s:String):{}{
        var res = {};
        var lastKey:String = null;
        while(StringUtils.codeAt(s,i)!="}".code){
            var c = StringUtils.codeAt(s,i);
            while(c==' '.code||c=='\n'.code||c=='\t'.code||c=='\r'.code||(lastKey==null&&c==','.code)){c = StringUtils.codeAt(s,++i);}
            if(c=="}".code&&(i++!=-1))break;
            if(lastKey==null){
                if(c==','.code)c = StringUtils.codeAt(s,++i);
                if(c=='"'.code){
                    i++;
                    lastKey = _parseString(s);
                }else{
                    throw "Malformed Json (Missing Object Key @"+i+"). Unexpected '"+c+"'";
                }
            }else{
                if(c==':'.code){
                    i++;
                    Reflect.setField(res,lastKey,parse(s,false));
                    //res[lastKey]=parse(s,false)
                    //res.set(lastKey,parse(s,false));
                    lastKey = null;
                }else{
                    throw "Malformed Json (Missing Object Value @"+i+"). Unexpected '"+c+"'";
                }
            }
        }
        return res;
    }

    static function _parseArray(s:String):Array<Dynamic>{
        var res = new Array<Dynamic>();
        var c;
        while((c=StringUtils.codeAt(s,i))!="]".code){
            if(c==','.code||c==' '.code)
                i++;
            res.push(parse(s,false));
        }
        i++;
        return res;
    }

    static function _parseString(s:String):String{
        var str = StringUtils.substr(s,i,s.indexOf('"',i+1));
        i+=str.length+1;
        return str;
    }

    static function _parseNumber(s:String):Dynamic{
        if(StringUtils.codeAt(s,i++)=='-'.code){
            return -_parseNumber_a(s);
        }else{
            i--;
            return _parseNumber_a(s);
        }
    }
    
    static var nums = ['0'.code,'1'.code,'2'.code,'3'.code,'4'.code,'5'.code,'6'.code,'7'.code,'8'.code,'9'.code];

    static function _parseNumber_a(s:String):Dynamic{
        //Ultra speed = dont regex... but my brain is too slow
        var st = i;

        var c = 0;

        var hex = false;
        var hasDot = false;
        var hasE = false;
        var iter = false;
        var prev = 0;

        while(true){
            if((++i)>=(s.length))break;
            c=StringUtils.codeAt(s,i);
            iter = false;
            if(c=='x'.code){
                if(prev=='0'.code&&!hex){
                    hex=true;
                    prev = c;
                    continue;
                }else{
                    throw "Invalid Number";
                }
            }
            if(c=='.'.code){
                if(!hasDot){
                    hasDot=true;
                    prev = c;
                    continue;
                }else{
                    throw "Invalid Number";
                }
            }
            if(prev=='e'.code||prev=='E'.code){
                iter = true;
                if(('0'.code==c || '1'.code==c || '2'.code==c || '3'.code==c || '4'.code==c || '5'.code==c || '6'.code==c || '7'.code==c || '8'.code==c || '9'.code==c || c=='+'.code || c=='-'.code)&&!hasE){
                    hasE = true;
                    prev = c;
                    continue;
                }else{
                    throw "Invalid Number";
                }
            }
            if(c=='e'.code||c=='E'.code)iter=true;
            if('0'.code!=c&&'1'.code!=c&&'2'.code!=c&&'3'.code!=c&&'4'.code!=c&&'5'.code!=c&&'6'.code!=c&&'7'.code!=c&&'8'.code!=c&&'9'.code!=c&&!iter){//nums.indexOf(c)==-1){
                break;
            }
            prev = c;
        }
        //i--;

        var f:Dynamic = 0;
        var d = StringUtils.substr(s,st,i);
        #if java
            untyped __java__('
                if(!hex){
                    
                    f = Float.parseFloat(d);
                }else{
                    f = Integer.parseInt("0x"+d);
                }
            ');
        #else
            if(!hex)
                f = Std.parseFloat(d);
            else
                f = Std.parseInt("0x"+d);
        #end
        return f;
    }
}