module half_adder_tb;
 
  reg bit1 = 0;
  reg bit2 = 0;
  wire w_SUM;
  wire w_CARRY;
   
  half_adder half_adder_inst
    (
     .A(bit1),
     .B(bit2),
     .Q(w_SUM),
     .Cout(w_CARRY)
     );
 
  initial
    begin
      bit1 = 1'b0;
      bit2 = 1'b0;
      #10;
      bit1 = 1'b0;
      bit2 = 1'b1;
      #10;
      bit1 = 1'b1;
      bit2 = 1'b0;
      #10;
      bit1 = 1'b1;
      bit2 = 1'b1;
      #10;
    end 
 
endmodule // half_adder_tb