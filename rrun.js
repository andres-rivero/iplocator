var R = require("r-script");
var out = R("C:/Users/Andres/Desktop/Elon/SQL/sqlmaster.R")
          .data(10)
          .callSync();

console.log(out);
