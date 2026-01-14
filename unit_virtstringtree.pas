unit unit_virtstringtree;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
  , SysUtils
  , laz.VirtualTrees
  , LCLIntf
  , LCLType
  ;

type

  PMyRecord = ^TMyRecord;
  TMyRecord = record
    ID: SizeInt;          // ID узла дерева
    ParentID: SizeInt;    // содержит для child-узла ID root-узла (для root-узла равен -1)
    ActionName: String;   // ссылка-имя на Action в произвольном ActList
    Caption: String;      // заголовок узла
    tsName: String;       // имя вкладки PageControl
  end;

  TRecArr = array of TMyRecord;

  // Вспомогательные классы для доступа к защищенным полям
  TBaseVirtualTreeAccess = class(TBaseVirtualTree)
  end;

  TLazVirtualStringTreeAccess = class(TLazVirtualStringTree)
  end;

  { TVirtStringTreeHelper }

  TVirtStringTreeHelper = class
  private
  public
    class function AddNode(aTree: TBaseVirtualTree; aNode: PVirtualNode; const AActionName, ACaption, AtsName: String): PVirtualNode;
    class procedure InitializeTree(aTree: TBaseVirtualTree); // устанавливает NodeDataSize
    class procedure SeralizeTree(aTree: TBaseVirtualTree; out aRecArr: TRecArr);
    class procedure DeseralizeTree(aTree: TBaseVirtualTree; aRecArr: TRecArr);
  end;


implementation

{ TVirtStringTreeHelper }
class function TVirtStringTreeHelper.AddNode(aTree: TBaseVirtualTree;
  aNode: PVirtualNode; const AActionName, ACaption, AtsName: String): PVirtualNode;
var
  Data: PMyRecord = nil;
  ParentID: SizeInt = 0;
begin
  Result := aTree.AddChild(aNode);

  if Assigned(aNode) then
  begin
    Data:= aTree.GetNodeData(aNode);
    ParentID := Data^.ID;
  end else ParentID := -1;

  Data:= aTree.GetNodeData(Result);

  Data^.ID := aTree.AbsoluteIndex(Result);
  Data^.ParentID := ParentID;
  Data^.ActionName := AActionName;
  Data^.Caption := ACaption;
  Data^.tsName := AtsName;
end;

class procedure TVirtStringTreeHelper.InitializeTree(aTree: TBaseVirtualTree);
begin
  // Используем вспомогательный класс для доступа к защищенному свойству
  TBaseVirtualTreeAccess(aTree).NodeDataSize := SizeOf(TMyRecord);
end;

class procedure TVirtStringTreeHelper.SeralizeTree(aTree: TBaseVirtualTree; out aRecArr: TRecArr);
var
  Node: PVirtualNode = nil;
  RecArr: TRecArr;
  i: SizeInt = 0;

  procedure AddNodeDataToRecArr(aTree: TBaseVirtualTree; aNode: PVirtualNode);
  var
    Data: PMyRecord = nil;
    ChildNode: PVirtualNode = nil;
  begin
    while Assigned(aNode) do
    begin
      Data:= nil;
      Data:= aTree.GetNodeData(aNode);

      SetLength(RecArr,Length(RecArr) + 1);
      RecArr[High(RecArr)]:= Data^;

      if (aNode^.ChildCount > 0) then
      begin
        ChildNode:= aNode^.FirstChild;
        AddNodeDataToRecArr(aTree,ChildNode);
      end;

      aNode:= aNode^.NextSibling;
    end;
  end;

begin
  //если дерево пустое
  if (TLazVirtualStringTreeAccess(aTree).RootNodeCount = 0) then Exit;

  SetLength(RecArr,0);
  Node:= aTree.GetFirst;
  AddNodeDataToRecArr(aTree, Node);

  //заполняем данными выходной буфер(массив)
  SetLength(aRecArr,0);

  for i := 0 to High(RecArr) do
  begin
    SetLength(aRecArr,Length(aRecArr) + 1);
    aRecArr[High(aRecArr)]:= RecArr[i];
  end;
end;

class procedure TVirtStringTreeHelper.DeseralizeTree(aTree: TBaseVirtualTree; aRecArr: TRecArr);
var
  tmpParentID: SizeInt = 0;
  tmpRecArr: TRecArr;
  i: SizeInt = 0;

  //возвращает кол-во элементов с ParentID = ChildID во входном массиве InRecArr,
  //при их наличии заполняет ими выходной массив OutRecArr
  function GetChildRecords(ChildID: SizeInt; InRecArr: TRecArr; out OutRecArr: TRecArr):SizeInt;
  var
    idx: SizeInt  = 0;
  begin
    Result:= 0;

    for idx := 0 to High(InRecArr) do
      if (InRecArr[idx].ParentID = ChildID) then Inc(Result);

    if (Result = 0) then Exit;

    SetLength(OutRecArr,0);//инициализируем выходной буфер-массив

    for idx := 0 to High(InRecArr) do
      if (InRecArr[idx].ParentID = ChildID) then
      begin
        SetLength(OutRecArr,Length(OutRecArr) + 1);
        OutRecArr[High(OutRecArr)]:= InRecArr[idx];
      end;
  end;

  //добавляет в дерево aTree узлы одного aParentID, если ParentNode определен,
  //то узлы будут дочерними, иначе - корневыми
  procedure AddNodeFromArray(aParentID: SizeInt; ParentNode: PVirtualNode = nil);
  var
    Node: PVirtualNode = nil;
    Data: PMyRecord = nil;
    _RecArr: TRecArr;
    j: SizeInt = 0;
  begin
    if (GetChildRecords(aParentID,aRecArr,_RecArr) = 0) then Exit;

    for j := 0 to High(_RecArr) do
    begin
      Node:= aTree.AddChild(ParentNode);
      Data:= aTree.GetNodeData(Node);
      Data^:= _RecArr[j];
    end;

    if Assigned(ParentNode)
      then Node:= ParentNode^.FirstChild
      else Node:= aTree.GetFirst;

    while Assigned(Node) do
    begin
      Data:= aTree.GetNodeData(Node);
      AddNodeFromArray(Data^.ID, Node);//добавляем вложенные узлы
      Node:= Node^.NextSibling;
    end;
  end;
begin
  aTree.BeginUpdate;
  try
    aTree.Clear;

    //если входной буфер-массив пуст
    if (Length(aRecArr) = 0) then Exit;

    tmpParentID:= 10000000;//задаем макс.вероятное значение

    //ищем наименьший ParentID (имеют root-узлы)
    for i:= 0 to High(aRecArr) do
      if (aRecArr[i].ParentID < tmpParentID) then tmpParentID:= aRecArr[i].ParentID;

    //ищем root-узлы
    if (GetChildRecords(tmpParentID,aRecArr,tmpRecArr) = 0) then Exit;

    AddNodeFromArray(tmpParentID);//ищем дочерние записи
  finally
    aTree.EndUpdate;
  end;
end;


end.

