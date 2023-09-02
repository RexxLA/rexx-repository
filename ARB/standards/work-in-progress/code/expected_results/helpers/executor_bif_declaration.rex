/*
Temporary declarations to have BIFs forwarding to RexxText.
*/

/* A global routine with the same name as a builtin function overrides this function. */
.globalRoutines["C2X"] = .routines~c2x
.globalRoutines["CASELESSCOMPARE"] = .routines~caselessCompare      -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSCOMPARETO"] = .routines~caselessCompareTo  -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSENDSWITH"] = .routines~caselessEndsWith    -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSEQUALS"] = .routines~caselessEquals        -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSLASTPOS"] = .routines~caselessLastPos      -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSMATCH"] = .routines~caselessMatch          -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSMATCHCHAR"] = .routines~caselessMatchChar  -- ooRexx BIM only, no BIF
.globalRoutines["CASELESSPOS"] = .routines~caselessPos              -- ooRexx BIM only, no BIF
.globalRoutines["CENTER"] = .routines~center
.globalRoutines["CENTRE"] = .routines~centre
.globalRoutines["COMPARE"] = .routines~compare
.globalRoutines["COMPARETO"] = .routines~compareTo                  -- ooRexx BIM only, no BIF
.globalRoutines["COPIES"] = .routines~copies
.globalRoutines["EQUALS"] = .routines~equals                        -- ooRexx BIM only, no BIF
.globalRoutines["ENDSWITH"] = .routines~endsWith                    -- ooRexx BIM only, no BIF
.globalRoutines["LENGTH"] = .routines~length
.globalRoutines["LEFT"] = .routines~left
.globalRoutines["LOWER"] = .routines~lower
.globalRoutines["MATCH"] = .routines~match                          -- ooRexx BIM only, no BIF
.globalRoutines["MATCHCHAR"] = .routines~matchChar                  -- ooRexx BIM only, no BIF
.globalRoutines["POS"] = .routines~pos
.globalRoutines["REVERSE"] = .routines~reverse
.globalRoutines["RIGHT"] = .routines~right
.globalRoutines["SUBCHAR"] = .routines~subChar
.globalRoutines["SUBSTR"] = .routines~substr
.globalRoutines["UPPER"] = .routines~upper

/*
No added value, Executor directly forward to String

.globalRoutines["C2D"] = .routines~c2d
.globalRoutines["HASHCODE"] = .routines~hashCode
.globalRoutines["X2B"] = .routines~x2b
.globalRoutines["X2C"] = .routines~x2c
.globalRoutines["X2D"] = .routines~x2d
*/
