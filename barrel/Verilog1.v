module half_adder 
  (A, B, Q,Cout);
 
  input  A;
  input  B;
  output Q;
  output Cout;
 
  assign q   = A ^ B;  // operace XOR
  assign Cout = A & B;  // operace AND
 
endmodule // half_adder
