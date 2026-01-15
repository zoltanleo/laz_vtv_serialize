unit u_main;

{$mode objfpc}{$H+}

interface

uses
  Classes
  , laz.VirtualTrees
  , SysUtils
  , Forms
  , Controls
  , Graphics
  , Dialogs
  , ExtCtrls
  , unit_virtstringtree
  , u_child
  ;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    vstMain: TLazVirtualStringTree;
    Panel1: TPanel;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure vstMainAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode
      );

  private
    FchildFrm: TfrmChild;
  public
    procedure vstMainNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure vstMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
              Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
    procedure LoadTreeFromChild;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormShow(Sender: TObject);
begin
  FchildFrm:= TfrmChild.Create(Self);
  with FchildFrm do
  begin
    Parent:= Panel1;
    BorderStyle:= bsNone;
    Align:= alClient;
    ShowInTaskBar:= stNever;
    Show;
  end;

  // Загружаем в основное дерево
  LoadTreeFromChild
end;

procedure TfrmMain.vstMainAddToSelection(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PMyRecord = nil;
  //Act: TBasicAction = nil;
begin
  Data := TBaseVirtualTree(Sender).GetNodeData(Node);
  if not Assigned(Data) then Exit;

    // --- Устанавливаем свойство, передав строку ---
  FchildFrm.CurrentActivePageName := Data^.tsName; // <<< Вот здесь

  //FchildFrm.PageControl1Change(Data^.tsName);

  // Ищем действие в ActList дочернего модуля
  //Act := FchildFrm.ActList.FindComponent(Data^.ActionName) as TBasicAction;

  //if Assigned(Act) then FchildFrm.PageControl1Change(Act);

  //if Assigned(Act) then
  //begin
  //  ShowMessage('Executing Action: ' + Act.Name);
  //  Act.Execute;
  //end
  //else
  //begin
  //  ShowMessage('Action not found: ' + Data^.ActionName);
  //end;
end;

procedure TfrmMain.vstMainNodeClick(Sender: TBaseVirtualTree;const HitInfo: THitInfo);
var
  Node: PVirtualNode = nil;
  Data: PMyRecord = nil;
  Act: TBasicAction = nil;
begin
  Node := TBaseVirtualTree(Sender).GetFirstSelected;
  if Assigned(Node) then
  begin
    Data := TBaseVirtualTree(Sender).GetNodeData(Node);

     //Ищем действие в ActList дочернего модуля
    Act := FchildFrm.ActList.FindComponent(Data^.ActionName) as TBasicAction;

    if Assigned(Act) then
    begin
      ShowMessage('Executing Action: ' + Act.Name);
      Act.Execute;
    end
    else
    begin
      ShowMessage('Action not found: ' + Data^.ActionName);
    end;


  end;
end;

procedure TfrmMain.vstMainGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: String);
var
  Data: PMyRecord = nil;
begin
  Data := vstMain.GetNodeData(Node);
  if not Assigned(Data) then Exit;

  case Column of
    0: CellText := Data^.Caption;
    else;
  end;
end;

procedure TfrmMain.LoadTreeFromChild;
begin
  vstMain.Clear;
  TVirtStringTreeHelper.DeseralizeTree(vstMain, FchildFrm.ChildRecArr);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // Настройка дерева
  TVirtStringTreeHelper.InitializeTree(vstMain);

  with vstMain do
  begin
    HintMode := hmTooltip;
    ShowHint := True;
    CheckImageKind:= ckSystemDefault;

    with Header do
    begin
      Columns.Clear;

      Columns.Add;
      //Columns[0].Text := CaptTreeStudyParam;
      //Columns[0].MinWidth:= cbbStaffSpec.Height * 7;
      Columns[0].Options:= Columns[0].Options + [coSmartResize] - [coEditable, coDraggable];
      //Columns[0].CaptionAlignment:= taCenter;
      //Columns[0].Style:= vsOwnerDraw;

      Height := Canvas.TextHeight('W') * 3 div 2;
      Options := Options + [hoAutoResize, hoOwnerDraw, hoShowHint, hoShowImages, hoVisible];
    end;

    with TreeOptions do
    begin
      AutoOptions := AutoOptions +
        [toAutoScroll, toAutoSpanColumns] - [];

      MiscOptions := MiscOptions +
        [toCheckSupport] - [toAcceptOLEDrop, toEditOnClick];
      PaintOptions := PaintOptions
        //+ [toShowVertGridLines, toShowHorzGridLines]
        - [toShowDropmark
          //, toShowTreeLines
            ];

      SelectionOptions := SelectionOptions +
        [toExtendedFocus, toFullRowSelect, toCenterScrollIntoView,
        toAlwaysSelectNode] - [toMultiSelect];
    end;

    //OnNodeClick := @vstMainNodeClick;
    OnGetText:= @vstMainGetText;
  end;


end;

end.

