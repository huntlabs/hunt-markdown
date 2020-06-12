module test.Common;

import hunt.util.StringBuilder;

string repeat(char ch, int count)
{
    StringBuilder buffer = new StringBuilder();

    for (int i = 0; i < count; ++i)
        buffer.append(ch);

    return buffer.toString();
}

string repeat(string s, int count)
{
    StringBuilder sb = new StringBuilder(s.length * count);
    for (int i = 0; i < count; i++)
    {
        sb.append(s);
    }
    return sb.toString();
}
