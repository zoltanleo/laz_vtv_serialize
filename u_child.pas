unit u_child;

{$mode ObjFPC}{$H+}

interface

uses
  Classes
  , ExtCtrls, SysUtils
  , Forms
  , Controls
  , Graphics
  , Dialogs
  , ComCtrls
  , StdCtrls
  , ActnList
  , laz.VirtualTrees
  , unit_virtstringtree
  ;

type
  { TfrmChild }

  TfrmChild = class(TForm)
    Button1: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    tsTwo_11: TTabSheet;
    tsTwo_12: TTabSheet;
    tsOne_1: TTabSheet;
    tsOne_2: TTabSheet;
    tsTwo_1: TTabSheet;
    tsTwo_2: TTabSheet;
    tsOne: TTabSheet;
    tsTwo: TTabSheet;
    tsThree: TTabSheet;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    FActList: TActionList;
    FChildRecArr: TRecArr;
    FchildVST: TLazVirtualStringTree;
    FPendingPageName: String; // --- Новое закрытое строковое поле ---
    procedure FillActionList;
    procedure CreateTree;
    procedure SetChildRecArr(AValue: TRecArr);
    procedure ActOneRootExecute(Sender: TObject);
    procedure SetPendingPageName(const AName: String);
  public
    property childVST: TLazVirtualStringTree read FchildVST;
    property ChildRecArr: TRecArr read FChildRecArr write SetChildRecArr;
    property ActList: TActionList read FActList;
    property CurrentActivePageName: String write SetPendingPageName;
  end;

var
  frmChild: TfrmChild;

implementation

{$R *.lfm}

{ TfrmChild }

procedure TfrmChild.FormCreate(Sender: TObject);
begin
  FchildVST:= TLazVirtualStringTree.Create(Self);
  TVirtStringTreeHelper.InitializeTree(FChildVST); // устанавливаем NodeDataSize
  FActList:= TActionList.Create(Self);

  FillActionList;
  CreateTree;
end;

procedure TfrmChild.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  CloseAction:= caFree;
end;

procedure TfrmChild.FormDestroy(Sender: TObject);
begin
  FActList.Free;
  FchildVST.Free;
end;

procedure TfrmChild.FormShow(Sender: TObject);
begin
  TVirtStringTreeHelper.SeralizeTree(FChildVST, FChildRecArr);
  Caption:= 'qwerty';
end;

procedure TfrmChild.PageControl1Change(Sender: TObject);
begin
  Label7.Caption:= PageControl1.ActivePage.Caption;

  //if TObject(Sender).InheritsFrom(TAction) then
  //  if (TAction(Sender).Name = 'ActOneRoot')
  //    then TAction(Sender).Execute
  //    else Label7.Caption:= TAction(Sender).Name;

  //for i := 0 to Pred(PageControl1.PageCount) do
  //begin
  //  if TAction(Sender).;
  //end;
  //
  //case PageControl1.ActivePage of
  //  tsOne: ;
  //  tsOne_1: TTabSheet;
  //  tsTwo_11: TTabSheet;
  //  tsTwo_12: TTabSheet;
  //  tsTwo: TTabSheet;
  //  tsOne_2: TTabSheet;
  //  tsTwo_1: TTabSheet;
  //  tsTwo_2: TTabSheet;
  //  tsThree: TTabSheet;
  //else ;
  //end;
end;

procedure TfrmChild.FillActionList;
begin
  with TAction.Create(FActList) do
  begin
    Name := 'ActOneRoot';
    Caption := 'Action One Root';
    ActionList := FActList;
    OnExecute:= @ActOneRootExecute;
  end;

  with TAction.Create(FActList) do
  begin
    Name := 'ActOneChild_1';
    Caption := 'Action One Child 1';
    ActionList := FActList;
  end;

  with TAction.Create(FActList) do
  begin
    Name := 'ActOneChild_2';
    Caption := 'Action One Child 2';
    ActionList := FActList;
  end;

  with TAction.Create(FActList) do
  begin
    Name := 'ActTwoRoot';
    Caption := 'Action Two Root';
    ActionList := FActList;
  end;

  with TAction.Create(FActList) do
  begin
    Name := 'ActTwoChild_1';
    Caption := 'Action Two Child 1';
    ActionList := FActList;
  end;

  with TAction.Create(FActList) do
  begin
    Name := 'ActTwoChild_2';
    Caption := 'Action Two Child 2';
    ActionList := FActList;
  end;

  with TAction.Create(FActList) do
  begin
    Name := 'ActThreeRoot';
    Caption := 'Action Three Root';
    ActionList := FActList;
  end;
end;

procedure TfrmChild.CreateTree;
var
  RootNode: PVirtualNode = nil;
  ChildNode: PVirtualNode = nil;
  NestedChildNode: PVirtualNode = nil;
begin
  // Создаем узлы с помощью хелпера
  RootNode := TVirtStringTreeHelper.AddNode(FChildVST, nil, 'ActOneRoot', 'Node One', 'tsOne');
  ChildNode := TVirtStringTreeHelper.AddNode(FChildVST, RootNode, 'ActOneChild_1', 'Node One Child 1', 'tsOne_1');
  ChildNode := TVirtStringTreeHelper.AddNode(FChildVST, RootNode, 'ActOneChild_2', 'Node One Child 2', 'tsOne_2');

  RootNode := TVirtStringTreeHelper.AddNode(FChildVST, nil, 'ActTwoRoot', 'Node Two', 'tsTwo');
  ChildNode := TVirtStringTreeHelper.AddNode(FChildVST, RootNode, 'ActTwoChild_1', 'Node Two Child 1', 'tsTwo_1');
    NestedChildNode := TVirtStringTreeHelper.AddNode(FChildVST, ChildNode, 'ActTwoChild_11', 'Node Two Child 11', 'tsTwo_11');
    NestedChildNode := TVirtStringTreeHelper.AddNode(FChildVST, ChildNode, 'ActTwoChild_12', 'Node Two Child 12', 'tsTwo_12');
  ChildNode := TVirtStringTreeHelper.AddNode(FChildVST, RootNode, 'ActTwoChild_2', 'Node Two Child 2', 'tsTwo_2');

  RootNode := TVirtStringTreeHelper.AddNode(FChildVST, nil, 'ActThreeRoot', 'Node Three', 'tsThree');
end;

procedure TfrmChild.SetChildRecArr(AValue: TRecArr);
begin
  if FChildRecArr= AValue then Exit;
  FChildRecArr:= AValue;
end;

procedure TfrmChild.ActOneRootExecute(Sender: TObject);
begin
  Label7.Caption:= FormatDateTime('dd.mm.yyyy nn:mm:ss:zzz', Now) ;
end;

procedure TfrmChild.SetPendingPageName(const AName: String);
var
  i: Integer;
  FoundTabSheet: TTabSheet;
begin
  FPendingPageName := AName;// Сохраняем имя, если нужно

  // Логика поиска и установки вкладки
  FoundTabSheet := nil;

  for i := 0 to Pred(PageControl1.PageCount) do
  begin
    if SameText(PageControl1.Pages[i].Name, FPendingPageName) then
    begin
      FoundTabSheet := PageControl1.Pages[i];
      Break;
    end;
  end;

  if Assigned(FoundTabSheet) then
  begin
    PageControl1.ActivePage := FoundTabSheet;
    if not (nboDoChangeOnSetIndex in PageControl1.Options) then PageControl1Change(Self);
  end;
end;

end.

