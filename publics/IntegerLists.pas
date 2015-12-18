unit IntegerLists;

interface

uses 
 Windows, SysUtils, Classes;

const
 MaxListLen = Maxint div 16;

type 
 TCompareResult=(crSame,crLarge,crSmall); 

 PIntArr = ^TIntArr; 
 TIntArr = array[0..MaxListLen - 1] of Integer; 

 TIntegers = class(TPersistent)
 private
   FList: PIntArr;      //数组指针 
   FCount: Integer;     //实际项目个数 
   FCapacity: Integer;  //库容量 
   FTag: Integer;
 protected
   function  Get(Index: Integer): Integer; 
   procedure Put(Index: Integer; Item: Integer); 
   procedure SetCount(NewCount: Integer); 
   procedure Grow; virtual; 
   procedure SetCapacity(NewCapacity: Integer); 
 public 
   destructor Destroy; override; 
   function  Add(Item: Integer): Integer; 
   procedure Clear; virtual; 
   procedure Delete(Index: Integer); 
   function  IndexOf(Item: Integer): Integer; 
   function  IndexOfAfter(After,Item: Integer): Integer; 
   function  CountOfItem(Item: Integer): Integer;  //值为Item的个数 
   function  Max: Integer;  //求最大值 
   procedure Insert(Index: Integer; Item: Integer); 
   function  Remove(Item: Integer): Integer; 
   property  Count: Integer read FCount write SetCount; 
   property  Items[Index: Integer]: Integer read Get write Put; default; 
   property  Capacity: Integer read FCapacity write SetCapacity; 
   property Tag: Integer read FTag write FTag;
   procedure LoadFromStream(Stream: TStream);
   procedure SaveToStream(Stream: TStream); 
   procedure AssignTo(Dest: TPersistent); override; 
   procedure Assign(Source: TPersistent); override; 
   function SumBefore(BeforeIndex:Integer):Integer; 
   function Sum(IndexArr:array of Integer):Integer; 
   function SumAll:Integer; 
   procedure Sort(araising:Boolean ); 
   procedure Reset(Value:Integer ); 
   procedure Exchange(Index1, Index2: Integer);     
   constructor Create; 
   function Min: Integer;
 end;

 TIntegerlist = class(TIntegers);

function SortIndexOfIntObj(aIntObj:TIntegers):TIntegers; //(13,12,17,13,16,19)权数=>排名(3,5,1,4,2,0)

implementation
////////////////////////////////////////////////////////////////////////////////////
function SortIndexOfIntObj(aIntObj:TIntegers):TIntegers; //(13,12,17,13,16,19)权数=>排名(3,5,1,4,2,0)
var aCount,aPos,i,j,aValue,Index,AfterPos:Integer;
   aValueObj,aCountObj,aTmpObj:TIntegers; 
begin//Result.Item[i]=aIntObj.Item值的排名  (13,12,17,13,16,19)=>(3,5,1,4,2,0) 13=0位权数=>0位排名
   Result:=TIntegers.Create;
   Result.Count:=aIntObj.Count;
   Result.Reset(0); 
   aValueObj:=TIntegers.Create; 
   aCountObj:=TIntegers.Create;
   aTmpObj:=TIntegers.Create; 
   aTmpObj.Assign(aIntObj);
   while (aTmpObj.Count>0) do begin
     aValue:=aTmpObj.Max;
     aCount:=aTmpObj.CountOfItem(aValue);
     aCountObj.Add(aCount); 
     aValueObj.Add(aValue); 
     for i :=0  to aCount-1 do  begin 
        Index:=aTmpObj.IndexOf(aValue); 
        aTmpObj.Delete(Index);//(13,12,17,13,16,19)权数 
     end;//=>aCountObj(1,1,1,1,2,1)权数的个数 
   end;      //=>aValueObj(19,17,16,13,12)权数值排列 
   Index:=0; 
   for i :=0  to aValueObj.Count-1 do begin 
      aValue:=aValueObj.Items[i]; 
      AfterPos:=0; 
      for j :=0  to aCountObj.Items[i]-1 do begin 
        aPos:=aIntObj.IndexOfAfter(AfterPos,aValue); //aValue=19,aPos=5
        AfterPos:=aPos+1; 
        Result.Items[aPos]:=Index;  //=>排名Index(3,5,1,4,2,0) 
        Inc(Index); 
      end; 
   end; 
   aTmpObj.Free; 
   aValueObj.Free; 
   aCountObj.Free; 
end; 
//////////////////////////////////////////////////////////////////////////////////// 

procedure TIntegers.Assign(Source: TPersistent); 
var  i,Len:Integer;
    aLst:TIntegers; 
begin
 if not (Source is TIntegers) then 
   raise Exception.Create('TIntegers.Assign Source isnot valid!'); 
 aLst:=(Source as TIntegers); 
 Clear;
 Len:=aLst.Count; 
 SetCount(Len); 
 for i :=0  to Len-1 do begin 
    Items[i]:=aLst.Items[i]; 
 end; 
end; 

procedure TIntegers.AssignTo(Dest: TPersistent); 
begin
 if not (Dest is TIntegers) then 
   raise Exception.Create('TIntegers.AssignTo Dest isnot valid!'); 
  (Dest as TIntegers).Assign(Self); 
end;
destructor TIntegers.Destroy; 
begin
 Clear; 
end; 

function TIntegers.Add(Item: Integer): Integer; 
begin
 Result := FCount; 
 if Result = FCapacity then 
   Grow; 
 FList^[Result] := Item; 
 Inc(FCount); 
end; 

procedure TIntegers.Clear; 
begin
 SetCount(0); 
 SetCapacity(0); 
end; 

constructor TIntegers.Create; 
begin
 inherited;
 inherited; 
 FCount:=0; 
 FCapacity:=0; 
 FList:=nil; 
 FTag:=0;
end;

procedure TIntegers.Delete(Index: Integer); 
begin
 if (Index < 0) or (Index >= FCount) then 
   raise Exception.Create('TIntegers.Delete Index isnot valid!'); 
 Dec(FCount);
 if Index < FCount then 
   System.Move(FList^[Index + 1], FList^[Index], 
     (FCount - Index) * SizeOf(Integer)); 
end; 

procedure TIntegers.Exchange(Index1, Index2: Integer); 
var i:Integer;
begin 
 i:=Items[Index1]; 
 Items[Index1]:=Items[Index2]; 
 Items[Index2]:=i; 
end; 

function TIntegers.Get(Index: Integer): Integer; 
begin
 if (Index < 0) or (Index >= FCount) then 
   raise Exception.Create('TIntegers.Get Index isnot valid!'); 
 Result := FList^[Index];
end; 

function TIntegers.IndexOf(Item: Integer): Integer; 
begin
 Result := 0; 
 while (Result < FCount) and (FList^[Result] <> Item) do 
   Inc(Result); 
 if Result = FCount then 
   Result := -1; 
end; 

procedure TIntegers.Put(Index: Integer; Item: Integer); 
begin
 if (Index < 0) or (Index >= FCount) then 
   raise Exception.Create('TIntegers.Put Index isnot valid!'); 
 FList^[Index] := Item;
end; 

procedure TIntegers.LoadFromStream(Stream: TStream); 
var Len:Integer;
begin 
 Clear; 
 Stream.Read(Len,SizeOf(Integer)); 
 SetCount(Len); 
 Stream.Read(FList^[0],Len*SizeOf(Integer)); 
end; 

procedure TIntegers.SaveToStream(Stream: TStream); 
var Len:Integer;
begin 
 Len:=Count; 
 Stream.Write(Len,SizeOf(Integer)); 
 Stream.Write(FList^[0],Len*SizeOf(Integer)); 
end; 

procedure TIntegers.Grow; 
var
 Delta: Integer; 
begin 
 if FCapacity > 64 then
   Delta := FCapacity div 4
 else
   if FCapacity > 8 then
     Delta := 16
   else
     Delta := 8;
 SetCapacity(FCapacity + Delta);
end;

procedure TIntegers.Insert(Index, Item: Integer); 
begin
 if (Index < 0) or (Index > FCount) then 
   raise Exception.Create('TIntegers.Insert Index isnot valid!'); 
 if FCount = FCapacity then
   Grow; 
 if Index < FCount then 
   System.Move(FList^[Index], FList^[Index + 1],(FCount - Index) * SizeOf(Integer)); 
 FList^[Index] := Item; 
 Inc(FCount); 
end; 

function TIntegers.IndexOfAfter(After, Item: Integer): Integer; 
var i:Integer;  //对包括索引After在内的Item进行检索
begin 
 Result:=-1; 
 for i :=After  to FCount-1 do begin 
   if Items[i]=Item then  begin 
      Result:=i; 
      Exit; 
   end; 
 end; 
end; 

function TIntegers.CountOfItem(Item: Integer): Integer; 
var i:Integer;
begin 
 Result:=0; 
 for i :=0  to FCount-1 do begin 
   if Items[i]=Item then  begin 
      Inc(Result); 
   end; 
 end; 
end; 

function TIntegers.Max: Integer; 
var i:Integer;
begin
 Result:=0; 
 if FCount=0 then Exit; 
 Result:=Items[0]; 
 for i :=1  to FCount-1 do begin 
   if Items[i]>Result then  begin 
      Result:=Items[i]; 
   end; 
 end; 
end; 

function TIntegers.Min: Integer;
var i:Integer;
begin 
 Result:=0;
 if FCount=0 then Exit;
 Result:=Items[0];
 for i :=1  to FCount-1 do begin
   if Items[i]<Result then  begin
      Result:=Items[i];
   end;
 end;
end;

function TIntegers.Remove(Item: Integer): Integer; 
begin
 Result := IndexOf(Item); 
 if Result >= 0 then 
   Delete(Result); 
end; 

procedure TIntegers.Reset(Value: Integer); 
var i:Integer;
begin //使用value值对所有Item填充 
 for i :=0  to Count-1 do begin 
   Items[i]:=Value; 
 end; 
end; 

procedure TIntegers.SetCount(NewCount: Integer); 
var  I: Integer;
begin 
 if (NewCount < 0) or (NewCount > MaxListSize) then 
   raise Exception.Create('TIntegers.SetCount NewCount isnot valid!'); 
 if NewCount > FCapacity then
   SetCapacity(NewCount); 
 if NewCount > FCount then 
   FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(Integer), 0) 
 else 
   for I := FCount - 1 downto NewCount do 
     Delete(I); 
 FCount := NewCount; 
end; 

procedure TIntegers.SetCapacity(NewCapacity: Integer); 
begin
 if (NewCapacity < FCount) or (NewCapacity > MaxListLen) then 
   raise Exception.Create('TIntegers.SetCapacity NewCapacity isnot valid!'); 
 if NewCapacity <> FCapacity then  begin
   ReallocMem(FList, NewCapacity * SizeOf(Integer)); 
   FCapacity := NewCapacity; 
 end; 
end; 

function TIntegers.SumBefore(BeforeIndex: Integer): Integer; 
var  i:Integer;
begin 
 Result:=0; 
 for i :=0  to BeforeIndex-1  do begin 
    Result:=Result+items[i]; 
 end; 
end; 

function TIntegers.Sum(IndexArr: array of Integer): Integer; 
var i,Index:Integer;
begin 
 Result:=0; 
 for i :=0  to Length(IndexArr)-1 do  begin 
    Index:= IndexArr[i]; 
    Result:=Result+Items[Index]; 
 end; 
end; 

function TIntegers.SumAll: Integer; 
var i:Integer;
begin 
 Result:=0; 
 for i :=0  to Count-1 do  begin 
    Result:=Result+Items[i]; 
 end; 
end; 

procedure TIntegers.Sort(araising: Boolean); 
var i,j,aValue:Integer; //aIntList:TIntegers; 
  function ItemCompare(Item1, Item2: Integer): TCompareResult;
  begin 
    Result:=crSame; 
    if Item1=Item2 then Exit; 
    if Item1>Item2 then 
      Result:=crLarge 
    else 
      Result:=crSmall; 
  end; 
begin 
 for i :=0  to Count-1 do  begin 
    aValue:=Items[i]; 
    for j :=i+1  to Count-1 do  begin 
         if araising then begin 
           if  ItemCompare(aValue,Items[j])=crLarge then 
              Exchange(i,j); 
         end else if  ItemCompare(aValue,Items[j])=crSmall then begin 
             Exchange(i,j); 
         end; 
    end; 
 end; 
end; 

end.
 
 
 
