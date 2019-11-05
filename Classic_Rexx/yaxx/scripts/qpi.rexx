/* Value of PI */
qpi:

PARSE ARG precision faster
IF precision="" THEN DO
   SAY "Precision?"
   PULL precision
   END
NUMERIC DIGITS precision

/* Setup Chudnovsky's coefs */
IF faster == "" THEN DO              /* for d = -163 (the best) */
   convergenceSpeed = 14
   k1 = 13591409
   k2 = 545140134
   k3 = 640320
   sqrt_k3 = 800; /* rough manual approx */
   END
ELSE DO                             /* for d = -427 (slower in final) */
   sqrt_61 = 8                      /* sqrt_61 using Newton-Raphson alg */
   DO n=1 by 1 TO 20
      sqrt_61 = sqrt_61 - (((sqrt_61 * sqrt_61) - 61) / (sqrt_61 * 2))
      END
   convergenceSpeed = 25
   k1 = (212175710912 * sqrt_61) + 1657145277365
   k2 = (13773980892672 * sqrt_61) + 107578229802750
   k3 = 5280 * ((30303 * sqrt_61) + 236674)
   sqrt_k3 = 50000; /* rough manual approx */
   END

/* Compute sqrt_k3 using Newton-Raphson alg */
DO n=1 by 1 TO 20   /* though 10 is largely enough! */
   sqrt_k3 = sqrt_k3 - (((sqrt_k3 * sqrt_k3) - k3) / (sqrt_k3 * 2))
   END

/* Now, iterate in Chudnovsky's terms */
s = 1
t = k1
k3_power3 = k3*k3*k3
DO n=1 BY 1 TO precision % convergenceSpeed
   s = -s *,
       (6*n) * (6*n-1) * (6*n-2) * (6*n-3) * (6*n-4) * (6*n-5),
       /,
       ((3*n) * (3*n-1) * (3*n-2) * n * n * n * k3_power3)
   t = t + s * (k1 + n*k2)
   END

/* Done.  Say the result. */
Say (k3 * sqrt_k3) / 12 / t
