/*
Temporary declarations to have BIFs forwarding to RexxText.
*/

/* A global routine with the same name as a builtin function overrides this function. */
.globalRoutines["C2X"] = .routines~c2x
.globalRoutines["CENTER"] = .routines~center
.globalRoutines["CENTRE"] = .routines~centre
.globalRoutines["COPIES"] = .routines~copies
.globalRoutines["LENGTH"] = .routines~length
.globalRoutines["LEFT"] = .routines~left
.globalRoutines["LOWER"] = .routines~lower
.globalRoutines["POS"] = .routines~pos
.globalRoutines["REVERSE"] = .routines~reverse
.globalRoutines["RIGHT"] = .routines~right
.globalRoutines["SUBSTR"] = .routines~substr
.globalRoutines["UPPER"] = .routines~upper

/*
No added value, Executor directly forward to String

.globalRoutines["C2D"] = .routines~c2d
.globalRoutines["X2B"] = .routines~x2b
.globalRoutines["X2C"] = .routines~x2c
.globalRoutines["X2D"] = .routines~x2d
*/
