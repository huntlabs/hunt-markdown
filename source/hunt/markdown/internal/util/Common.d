/*
 * hunt-time: A time library for D programming language.
 *
 * Copyright (C) 2015-2018 HuntLabs
 *
 * Website: https://www.huntlabs.net/
 *
 * Licensed under the Apache-2.0 License.
 *
 */
module hunt.markdown.internal.util.Common;

public import std.traits;
public import std.array;

string MakeGlobalVar(T)(string var, string init = null)
{
    string str;
    str ~= `__gshared ` ~ T.stringof ~ ` _` ~ var ~ `;`;
    str ~= "\r\n";
    if (init is null)
    {
        str ~= `public static ref ` ~ T.stringof ~ ` ` ~ var ~ `()
            {
                static if(isAggregateType!(`~ T.stringof ~`))
                {
                    if(_` ~ var ~ ` is null)
                    {
                        _`~ var ~ `= new ` ~ T.stringof ~ `();
                    }
                }
                else static if(isArray!(`~ T.stringof ~ `))
                {
                    if(_` ~ var ~ `.length == 0 )
                    {
                        _`~ var ~ `= new ` ~ T.stringof ~ `;
                    }
                }
                else
                {
                    if(_` ~ var ~ ` == `~ T.stringof.replace("[]","") ~`.init )
                    {
                        _`~ var ~ `= new ` ~ T.stringof ~ `();
                    }
                }
                
                return _` ~ var ~ `;
            }`;
    }
    else
    {
        str ~= `public static ref ` ~ T.stringof ~ ` ` ~ var ~ `()
            {
                static if(isAggregateType!(`~ T.stringof ~`))
                {
                    if(_` ~ var ~ ` is null)
                    {
                        _`~ var ~ `= ` ~ init ~ `;
                    }
                }
                else static if(isArray!(`~ T.stringof ~ `))
                {
                    if(_` ~ var ~ `.length == 0 )
                    {
                        _`~ var ~ `= ` ~ init ~ `;
                    }
                }
                else
                {
                    if(_` ~ var ~ ` == `~ T.stringof.replace("[]","") ~`.init )
                    {
                        _`~ var ~ `= ` ~ init ~ `;
                    }
                }
               
                return _` ~ var ~ `;
            }`;
    }

    return str;
}


