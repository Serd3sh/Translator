#include <stdio.h>
#define true 1
#define false 0

int pow(int x, int y) {
	int i;
	int res = 1;
	for (i=1;i<=y;i++) { // WARNING: Possible incorrect cycle direction conversion due using variables
		res=res*x;
	};
	return res;
};
int main() {
	int x;
	int i;
	char oddFound;
	x=1;
	oddFound=false;
	// main cycle FOR i := 1 TO 10 DO
	for (i=1;i<=10;i++) {
		if (i<4) {
			x=x+i*pow(-1, i);
			printf("Range: < 4");
		} else if (i==6) {
			while (x>20) {
				x=x-x/4;
			};
			x=x+i*i;
			printf("Specific: = 6");
		} else {
			x=x+i;
			printf("Other");
		};
		if (x%2==1) {
			oddFound=true;
		};
	};
	// print results
	if (x>50&&oddFound==true) {
		printf("%d", x+100);
	} else {
		printf("%d", x);
	};
	return 0;
};
