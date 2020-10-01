#include <bits/stdc++.h>
#define pc putchar
#define gc getchar
#define gcu getchar_unlocked
#define fi first
#define se second
#define pb push_back
#define mod ((ll)1e9 + 7)
typedef long long ll;
typedef unsigned long long ull;
using namespace std;
//===============================================================================================
 
int n;
inline int fsc()
{
    int c, ret = 0;
    while ((c = gcu()) >= '0' && c <= '9')
        ret = (ret << 3) + (ret << 1) + c - '0';
    return ret;
}
 
//===============================================================================================
int main()
{
    n = fsc();
    for (int i = 0, tempa, tempb; i < n; i++)
    {
        tempa = fsc();
        tempb = fsc();
        printf("%d\n", min(tempa, tempb - 1));
    }
}
//===============================================================================================