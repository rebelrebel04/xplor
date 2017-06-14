dup(mtcars, disp)
cpf(mtcars, !duplicated(disp))

dup(mtcars, disp, wt = "hp")
print(dup(mtcars, disp))



dup(mtcars, disp == 79)
cpf(mtcars, disp == 79)
cpf(mtcars, gear)
