unit ChatWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Math, StdCtrls, ExtCtrls, ChatControl, Vcl.ComCtrls, RichEdit;

type
  TForm4 = class(TForm)

    Panel1: TPanel;
    Panel2: TPanel;
    LabeledEdit1: TLabeledEdit;
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    ChatControl1: TInjectChatControl;
    Button2: TButton;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
  private
    procedure RichEditToCanvas(RichEdit: TRichEdit; Canvas: TCanvas;
      PixelsPerInch: Integer);
    procedure TestRichMode;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation

{$R *.dfm}

procedure TForm4.RichEditToCanvas(RichEdit: TRichEdit; Canvas: TCanvas; PixelsPerInch: Integer);
var
  ImageCanvas: TCanvas;
  fmt: TFormatRange;
begin
  ImageCanvas := Canvas;
  with fmt do
  begin
    hdc:= ImageCanvas.Handle;
    hdcTarget:= hdc;
    // rect needs to be specified in twips (1/1440 inch) as unit
    rc:=  Rect(0, 0,
                ImageCanvas.ClipRect.Right * 1440 div PixelsPerInch,
                ImageCanvas.ClipRect.Bottom * 1440 div PixelsPerInch
              );
    rcPage:= rc;
    chrg.cpMin := 0;
    chrg.cpMax := RichEdit.GetTextLen;
  end;
  SetBkMode(ImageCanvas.Handle, TRANSPARENT);
  RichEdit.Perform(EM_FORMATRANGE, 1, Integer(@fmt));
  // next call frees some cached data
  RichEdit.Perform(EM_FORMATRANGE, 0, 0);
end;

procedure TForm4.TestRichMode;
begin
//   RichEditToCanvas(RichEdit1, Image1.Canvas, Self.PixelsPerInch);
//   Image1.Refresh;
end;

procedure TForm4.Button1Click(Sender: TObject);
var
  i: integer;
begin
  ChatControl1.Strings.Clear;
  for i := 0 to StrToInt(LabeledEdit1.Text) - 1 do
    ChatControl1.Say(TUser(Random(2)),'MEU NOME', 'testando...');
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  TestRichMode;
end;

procedure TForm4.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  Assert(Sender is TEdit);
  if ord(Key) = VK_RETURN then
  begin
    ChatControl1.Say(TUser(TEdit(Sender).Tag), 'USER'+TEdit(Sender).Tag.ToString+' : ',TEdit(Sender).Text);
    Key := #0;
    TEdit(Sender).Clear;
  end;
end;

end.
