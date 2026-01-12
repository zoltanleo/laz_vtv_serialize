unit unit_virtstringtree;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, laz.VirtualTrees, LCLIntf, LCLType;

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

  // Вспомогательный класс для доступа к защищенным полям
  TBaseVirtualTreeAccess = class(TBaseVirtualTree)
  end;

  { TVirtStringTreeHelper }

  TVirtStringTreeHelper = class
  private
  public
    class function GetRootNodeCnt(aTree: TBaseVirtualTree): PtrUInt;
    class function AddNode(aTree: TBaseVirtualTree; aNode: PVirtualNode; const AActionName, ACaption, AtsName: String): PVirtualNode;
    class procedure InitializeTree(aTree: TBaseVirtualTree); // устанавливает NodeDataSize
    class procedure SeralizeTree(aTree: TBaseVirtualTree; aRecArr: TRecArr);
    class procedure DeseralizeTree(aTree: TBaseVirtualTree; aRecArr: TRecArr);
  end;


implementation

{ TVirtStringTreeHelper }

class function TVirtStringTreeHelper.GetRootNodeCnt(aTree: TBaseVirtualTree): PtrUInt;
var
  Node: PVirtualNode = nil;
  cnt: PtrUInt = 0;
begin
  Result:= 0;
  Node:= aTree.GetFirst;

  while Assigned(Node) do
  begin
    Inc(cnt);
    Result:= cnt;
    Node:= Node^.NextSibling;
  end;
end;

class function TVirtStringTreeHelper.AddNode(aTree: TBaseVirtualTree;
  aNode: PVirtualNode; const AActionName, ACaption, AtsName: String): PVirtualNode;
var
  Data: PMyRecord = nil;
  ParentID: SizeInt = 0;
begin
  Result := aTree.AddChild(aNode);
  Data := aTree.GetNodeData(Result);

  if not Assigned(aNode)
     then ParentID := -1
     else ParentID := PMyRecord(aTree.GetNodeData(Result))^.ID;

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

class procedure TVirtStringTreeHelper.SeralizeTree(aTree: TBaseVirtualTree; aRecArr: TRecArr);
var
  Node: PVirtualNode = nil;

  procedure AddNodeDataToRecArr(aTree: TBaseVirtualTree; aNode: PVirtualNode);
  var
    Data: PMyRecord = nil;
    ChildNode: PVirtualNode = nil;
  begin
    while Assigned(aNode) do
    begin
      Data:= nil;
      Data:= aTree.GetNodeData(aNode);

      SetLength(aRecArr,Length(aRecArr) + 1);
      aRecArr[High(aRecArr)]:= Data^;

      if (aNode^.ChildCount > 0) then
      begin
        ChildNode:= aNode^.FirstChild;
        AddNodeDataToRecArr(aTree,ChildNode);
      end;

      aNode:= aNode^.NextSibling;
    end;
  end;

begin
  if (GetRootNodeCnt(aTree) = 0) then Exit;

  SetLength(aRecArr,0);
  Node:= aTree.GetFirst;
  AddNodeDataToRecArr(aTree, Node);
end;

class procedure TVirtStringTreeHelper.DeseralizeTree(aTree: TBaseVirtualTree; aRecArr: TRecArr);
begin

end;


end.

