#include "kernel/param.h"
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int g(int x) {
  return x+3;
}

int f(int x) {
  return g(x);
}

int addAmulAsubAdiv(int a, int b){
  int sum = 0;
  sum = a + b;
  sum *= a * b;
  sum = g(sum);
  sum -= a;
  sum /= b;
  return sum;
}

void main(void) {
  int a = 10;
  int b = 15;
  int sum = addAmulAsubAdiv(a, b);
  printf("%d", sum);

  printf("%d %d\n", f(8)+1, 13);

  unsigned int i = 0x00646c72;
  printf("H%x Wo%s", 57616, &i);

  printf("x=%d y=%d", 3);
  exit(0);
}
