unit uMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.FMXUI.Wait, FireDAC.Stan.Param, FireDAC.DatS,
  FireDAC.DApt.Intf, FireDAC.DApt, FMX.ListView.Types, FMX.ListView.Appearances,
  FMX.ListView.Adapters.Base, System.Rtti, System.Bindings.Outputs,
  Fmx.Bind.Editors, Data.Bind.EngExt, Fmx.Bind.DBEngExt, Data.Bind.Components,
  Data.Bind.DBScope, FMX.ListView, FMX.StdCtrls, FMX.Controls.Presentation,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FMX.DialogService.Async,
  System.IOUtils;

type
  TFrmMain = class(TForm)
    ConexaoBD: TFDConnection;
    FDQueryCreateTable: TFDQuery;
    ToolBar1: TToolBar;
    ButtonAdd: TButton;
    ButtonDelete: TButton;
    Label1: TLabel;
    ListView1: TListView;
    BindSourceDB1: TBindSourceDB;
    FDQuery1: TFDQuery;
    LinkFillControlToFieldShopItem: TLinkFillControlToField;
    BindingsList1: TBindingsList;
    FDQueryInsert: TFDQuery;
    FDQueryDelete: TFDQuery;
    procedure ListView1ItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure ButtonAddClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ConexaoBDBeforeConnect(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure OnInputQuery_Close(const AResult: TModalResult; const AValues: array of string);
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.fmx}

procedure TFrmMain.ButtonAddClick(Sender: TObject);
begin
  TDialogServiceAsync.InputQuery('Enter New Item', ['Name'], [''], Self.OnInputQuery_Close)
end;

procedure TFrmMain.ButtonDeleteClick(Sender: TObject);
var
  TaskName: String;
begin
  TaskName := TListViewItem(ListView1.Selected).Text;

  try
    FDQueryDelete.ParamByName('ShopItem').AsString := TaskName;
    FDQueryDelete.ExecSQL();
    FDQuery1.Close;
    FDQuery1.Open;
    ButtonDelete.Visible := ListView1.Selected <> nil;
  except
    on e: Exception do
    begin
      SHowMessage(e.Message);
    end;
  end;
end;

procedure TFrmMain.ConexaoBDBeforeConnect(Sender: TObject);
var
  dbPath: string;
begin
{$IF DEFINED(iOS) or DEFINED(ANDROID)}
  dbPath := TPath.Combine(TPath.GetDocumentsPath, 'shoplist.db');
  ConexaoBD.Params.Values['Database'] := dbPath;
{$ENDIF}
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  FDQueryCreateTable.ExecSQL;
end;

procedure TFrmMain.ListView1ItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
  ButtonDelete.Visible := ListView1.Selected <> nil
end;

procedure TFrmMain.OnInputQuery_Close(const AResult: TModalResult;
  const AValues: array of string);
var
  TaskName: String;
begin
 TaskName := string.Empty;
  if AResult <> mrOk then
    Exit;
  TaskName := AValues[0];
  try
    if (TaskName.Trim <> '')
    then
    begin
      FDQueryInsert.ParamByName('ShopItem').AsString := TaskName;
      FDQueryInsert.ExecSQL();
      FDQuery1.Close();
      FDQuery1.Open;
      ButtonDelete.Visible := ListView1.Selected <> nil;
    end;
  except
    on e: Exception do
    begin
      ShowMessage(e.Message);
    end;
  end;
end;

end.
