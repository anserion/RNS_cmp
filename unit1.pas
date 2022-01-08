//Copyright 2021 Andrey S. Ionisyan (anserion@gmail.com)
//
//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.

unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    BTN_P_set: TButton;
    BTN_calc: TButton;
    Edit_op2: TEdit;
    Edit_res: TEdit;
    Edit_op1: TEdit;
    Label1: TLabel;
    Label5: TLabel;
    Label_op1_op2_equ: TLabel;
    Label10: TLabel;
    Label12: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label9: TLabel;
    Label_P: TLabel;
    SG_P: TStringGrid;
    SG_RNS_sub_mrs: TStringGrid;
    SG_ROM_digits: TStringGrid;
    SG_RNS_op2: TStringGrid;
    SG_RNS_op1: TStringGrid;
    SG_ROM_small_numbers: TStringGrid;
    SG_ROM_P_inv: TStringGrid;
    procedure BTN_P_setClick(Sender: TObject);
    procedure BTN_calcClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure ROM_digits_calc;
    procedure ROM_small_numbers_calc;
    procedure ROM_P_inv_calc;
    procedure ROM_add_calc;
    procedure ROM_sub_calc;
    procedure ROM_mul_calc;
    procedure Op1_to_RNS_calc;
    procedure Op2_to_RNS_calc;
    procedure RNS_sub_calc;
    procedure RNS_sub_MRS_calc;
    function op1_op2_equ:boolean;
  public

  end;

const max_p=255;

var
  Form1: TForm1;

  P:array[1..8]of integer;
  PP:LongInt;
  op1_dec,op2_dec,res_dec:integer;
  ROM_add:array[1..8,0..max_p-1,0..max_p-1]of integer;
  ROM_sub:array[1..8,0..max_p-1,0..max_p-1]of integer;
  ROM_mul:array[1..8,0..max_p-1,0..max_p-1]of integer;
  ROM_digits:array[1..8,0..200]of integer;
  ROM_P_inv:array[1..8,1..8]of integer;
  ROM_small_numbers:array[1..8,0..255]of integer;
  op1_RNS:array[1..8]of integer;
  op2_RNS:array[1..8]of integer;
  sub_RNS:array[1..8]of integer;
  MRS_RNS:array[1..8]of integer;
  flag_equ:boolean;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ROM_small_numbers_calc;
var i,k:integer;
begin
  for i:=0 to 255 do
    for k:=1 to 8 do
        ROM_small_numbers[k,i]:=i mod P[k];
end;

procedure TForm1.ROM_sub_calc;
var k,i,j:integer;
begin
  for k:=1 to 8 do
    for i:=0 to P[k]-1 do
      for j:=0 to P[k]-1 do
        ROM_sub[k,i,j]:=(i-j+P[k]) mod P[k];
end;

procedure TForm1.ROM_mul_calc;
var k,i,j:integer;
begin
  for k:=1 to 8 do
    for i:=0 to P[k]-1 do
      for j:=0 to P[k]-1 do
        ROM_mul[k,i,j]:=(i*j) mod P[k];
end;

procedure TForm1.ROM_add_calc;
var k,i,j:integer;
begin
  for k:=1 to 8 do
    for i:=0 to P[k]-1 do
      for j:=0 to P[k]-1 do
        ROM_add[k,i,j]:=(i+j) mod P[k];
end;

procedure TForm1.ROM_digits_calc;
var i,j,k,tmp:integer;
begin
  for k:=1 to 8 do
  begin
    tmp:=1; ROM_digits[k,0]:=0;
    for i:=0 to 8 do
    begin
      for j:=1 to 10 do ROM_digits[k,i*9+j]:=(tmp*j)mod P[k];
      tmp:=tmp*10;
    end;
  end;
end;

procedure TForm1.ROM_P_inv_calc;
var i,j,k:integer;
begin
  for k:=1 to 8 do
    for i:=1 to 8 do
    begin
      ROM_P_inv[k,i]:=0;
      for j:=1 to P[k]-1 do
        if ((P[i]*j)mod P[k])=1 then ROM_P_inv[k,i]:=j;
    end;
end;

procedure TForm1.Op1_to_RNS_calc;
var k,i,tmp,tmp_pow,digit,digits_num:integer;
begin
  tmp:=op1_dec;
  if tmp=0 then digits_num:=1 else digits_num:=0;
  while tmp>0 do begin tmp:=tmp div 10; digits_num:=digits_num+1; end;
  SG_RNS_op1.RowCount:=digits_num+2;

  tmp:=op1_dec; tmp_pow:=1;
  for k:=1 to 8 do op1_RNS[k]:=0;
  for i:=0 to digits_num-1 do
  begin
    digit:=tmp mod 10;
    SG_RNS_op1.Cells[0,digits_num-i]:=IntToStr(digit*tmp_pow);
    if digit<>0 then
    for k:=1 to 8 do
    begin
      SG_RNS_op1.Cells[k,digits_num-i]:=IntToStr(ROM_digits[k,digit+i*9]);
      op1_RNS[k]:=ROM_add[k,op1_RNS[k],ROM_digits[k,digit+i*9]];
    end
    else for k:=1 to 8 do SG_RNS_op1.Cells[k,digits_num-i]:='0';
    tmp:=tmp div 10; tmp_pow:=tmp_pow*10;
  end;

  SG_RNS_op1.Cells[0,digits_num+1]:='Итого(СОК)';
  for k:=1 to 8 do SG_RNS_op1.Cells[k,digits_num+1]:=IntToStr(op1_RNS[k]);
end;

procedure TForm1.Op2_to_RNS_calc;
var k,i,tmp,tmp_pow,digit,digits_num:integer;
begin
  tmp:=op2_dec;
  if tmp=0 then digits_num:=1 else digits_num:=0;
  while tmp>0 do begin tmp:=tmp div 10; digits_num:=digits_num+1; end;
  SG_RNS_op2.RowCount:=digits_num+2;

  tmp:=op2_dec; tmp_pow:=1;
  for k:=1 to 8 do op2_RNS[k]:=0;
  for i:=0 to digits_num-1 do
  begin
    digit:=tmp mod 10;
    SG_RNS_op2.Cells[0,digits_num-i]:=IntToStr(digit*tmp_pow);
    if digit<>0 then
    for k:=1 to 8 do
    begin
      SG_RNS_op2.Cells[k,digits_num-i]:=IntToStr(ROM_digits[k,digit+i*9]);
      op2_RNS[k]:=ROM_add[k,op2_RNS[k],ROM_digits[k,digit+i*9]];
    end
    else for k:=1 to 8 do SG_RNS_op2.Cells[k,digits_num-i]:='0';
    tmp:=tmp div 10; tmp_pow:=tmp_pow*10;
  end;

  SG_RNS_op2.Cells[0,digits_num+1]:='Итого(СОК)';
  for k:=1 to 8 do SG_RNS_op2.Cells[k,digits_num+1]:=IntToStr(op2_RNS[k]);
end;

procedure TForm1.RNS_sub_calc;
var k:integer;
begin
  for k:=1 to 8 do sub_RNS[k]:=ROM_sub[k,op1_RNS[k],op2_RNS[k]];
  for k:=1 to 8 do SG_RNS_sub_mrs.Cells[k,1]:=IntToStr(sub_RNS[k]);
end;

procedure TForm1.RNS_sub_MRS_calc;
var k,i:integer;
begin
  for i:=2 to 8 do
  begin
    MRS_RNS[i]:=sub_RNS[i];
    for k:=1 to 8 do
      sub_RNS[k]:=ROM_sub[k,sub_RNS[k],ROM_small_numbers[k,MRS_RNS[i]]];
    SG_RNS_sub_mrs.Cells[0,2*(i-1)]:='-'+IntToStr(MRS_RNS[i]);
    for k:=1 to 8 do SG_RNS_sub_mrs.Cells[k,2*(i-1)]:=IntToStr(sub_RNS[k]);

    for k:=1 to 8 do
      sub_RNS[k]:=ROM_mul[k,sub_RNS[k],ROM_P_inv[k,i]];
    SG_RNS_sub_mrs.Cells[0,2*i-1]:='div '+IntToStr(P[i]);
    for k:=1 to 8 do SG_RNS_sub_mrs.Cells[k,2*i-1]:=IntToStr(sub_RNS[k]);
  end;
  MRS_RNS[1]:=sub_RNS[1];
  for k:=1 to 8 do SG_RNS_sub_mrs.Cells[k,4]:=IntToStr(MRS_RNS[k]);
end;

function TForm1.op1_op2_equ:boolean;
var k:integer; flag:boolean;
begin
  flag:=true;
  for k:=1 to 8 do
      if op1_RNS[k]<>op2_RNS[k] then flag:=false;
  op1_op2_equ:=flag;
end;

procedure TForm1.BTN_calcClick(Sender: TObject);
begin
  op1_dec:=StrToInt(Edit_op1.text);
  if op1_dec<0 then op1_dec:=0;
  if op1_dec>100000000 then op1_dec:=100000000;
  Edit_op1.text:=IntToStr(op1_dec);

  op2_dec:=StrToInt(Edit_op2.text);
  if op2_dec<0 then op2_dec:=0;
  if op2_dec>100000000 then op2_dec:=100000000;
  Edit_op2.text:=IntToStr(op2_dec);

  op1_to_RNS_calc;
  op2_to_RNS_calc;

  flag_equ:=op1_op2_equ;
  if flag_equ
  then Label_op1_op2_equ.caption:='Проверка первого и второго чисел на равенство: Равны'
  else Label_op1_op2_equ.caption:='Проверка первого и второго чисел на равенство: Не равны';

  RNS_sub_calc;
  RNS_sub_MRS_calc;
  if flag_equ
  then Edit_res.text:='Числа равны'
  else
    begin
      if MRS_RNS[1]=0 then Edit_res.text:='Первое число больше';
      if MRS_RNS[1]=1 then Edit_res.text:='Второе число больше';
    end;
end;

procedure TForm1.BTN_P_setClick(Sender: TObject);
var k,i,tmp:integer;
begin
  for k:=1 to 8 do if not(TryStrToInt(SG_P.Cells[k-1,0],tmp)) then SG_P.Cells[k-1,0]:='1';
  for k:=1 to 8 do P[k]:=StrToInt(SG_P.Cells[k-1,0]);
  for k:=1 to 8 do if P[k]>max_p then P[k]:=1;
  for k:=1 to 8 do SG_P.Cells[k-1,0]:=IntToStr(P[k]);

  PP:=1; for k:=1 to 8 do PP:=PP*P[k];
  ROM_add_calc;
  ROM_sub_calc;
  ROM_mul_calc;
  ROM_digits_calc;
  ROM_small_numbers_calc;
  ROM_P_inv_calc;

  Label_P.caption:='Диапазон СОК: '+IntToStr(PP);
  for k:=1 to 8 do SG_ROM_digits.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);
  for k:=1 to 8 do SG_ROM_P_inv.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);
  for k:=1 to 8 do SG_ROM_small_numbers.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);
  for k:=1 to 8 do SG_RNS_op1.Cells[k,0]:=IntToStr(P[k]);
  for k:=1 to 8 do SG_RNS_op2.Cells[k,0]:=IntToStr(P[k]);
  for k:=1 to 8 do SG_RNS_sub_mrs.Cells[k,0]:='p'+IntToStr(k)+'='+IntToStr(P[k]);

  SG_ROM_digits.RowCount:=84;
  SG_ROM_digits.Cells[0,1]:=IntToStr(0);
  tmp:=1;
  for i:=0 to 8 do
  begin
    for k:=1 to 10 do SG_ROM_digits.Cells[0,i*9+k+1]:=IntToStr(tmp*k);
    tmp:=tmp*10;
  end;
  for k:=1 to 8 do
    for i:=0 to 82 do
      SG_ROM_digits.Cells[k,i+1]:=IntToStr(ROM_digits[k,i]);

  for i:=0 to 255 do
  begin
    SG_ROM_small_numbers.Cells[0,i+1]:=IntToStr(i);
    for k:=1 to 8 do
      SG_ROM_small_numbers.Cells[k,i+1]:=IntToStr(ROM_small_numbers[k,i]);
  end;

  for i:=1 to 8 do
  begin
    SG_ROM_P_inv.Cells[0,i]:=IntToStr(P[i])+'^(-1)=';
    for k:=1 to 8 do
      SG_ROM_P_inv.Cells[k,i]:=IntToStr(ROM_P_inv[k,i]);
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
var i:integer;
begin
  SG_P.Cells[0,0]:='2';
  SG_P.Cells[1,0]:='3';
  SG_P.Cells[2,0]:='5';
  SG_P.Cells[3,0]:='7';
  SG_P.Cells[4,0]:='11';
  SG_P.Cells[5,0]:='13';
  SG_P.Cells[6,0]:='17';
  SG_P.Cells[7,0]:='19';

  SG_RNS_op1.Cells[0,0]:='разряд';
  SG_RNS_op2.Cells[0,0]:='разряд';

  SG_RNS_sub_mrs.Cells[0,0]:='основания';
  SG_RNS_sub_mrs.Cells[0,1]:='op1-op2';

  SG_ROM_digits.Cells[0,0]:='число';
  SG_ROM_small_numbers.Cells[0,0]:='число';
  SG_ROM_P_inv.Cells[0,0]:='число';

  BTN_P_setClick(self);
  BTN_CalcClick(self);
end;

end.

