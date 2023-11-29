FUNCTION pow : INT
	VAR_ARG
		x : INT;
		y : INT;
	END_VAR;
	VAR
		i : INT;
		res : INT := 1;
	END_VAR;
	FOR i := 1 TO y DO
		res := res * x;
	END_FOR;
	RETURN res;
END_FUNCTION;
PROGRAM meow
	VAR
		x : INT;
		i : INT;
		oddFound : BOOL;
	END_VAR;
	x := 1;
	oddFound := FALSE;
	// main cycle FOR i := 1 TO 10 DO
	FOR i := 1 TO 10 DO
		IF i < 4 THEN
			x := x + i * pow(-1, i);
			print("Range: < 4");
		ELSIF i = 6 THEN
			WHILE x > 20 DO
				x := x - x/4;
			END_WHILE;
			x := x + i*i;
			print("Specific: = 6");
		ELSE
			x := x + i;
			print("Other");
		END_IF;
		IF x MOD 2 = 1 THEN
			oddFound := TRUE;
		END_IF;
	END_FOR;
	// print results
	IF x > 50 AND oddFound = TRUE THEN
		print(x + 100);
	ELSE
		print(x);
	END_IF;
END_PROGRAM;