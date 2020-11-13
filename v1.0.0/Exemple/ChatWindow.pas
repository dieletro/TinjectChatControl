unit ChatWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Math, StdCtrls, ExtCtrls, ChatControl, Vcl.ComCtrls, RichEdit,
  Vcl.Imaging.pngimage, SpeechBubble, Balloon;

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
    OpenDlg: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
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
var
  MessageInfo: TMessageInfo;
begin
  MessageInfo := TMessageInfo.Create;
  MessageInfo.User := TUser(TEdit(Sender).Tag);
  MessageInfo.MessageID := Random(128);
  MessageInfo.ChatID := 1234;
  MessageInfo.UserName := 'diegolacerdamenezes';
  MessageInfo.FirstName := 'Ruan Diego';
  MessageInfo.LastName := 'Lacerda Menezes';
  MessageInfo.PhoneNumber := '+5521997196000';
  MessageInfo.Message := TEdit(Sender).Text;


  ChatControl1.Strings.Clear;
  for i := 0 to StrToInt(LabeledEdit1.Text) - 1 do
                     //TUser(Random(2))
    ChatControl1.Say(MessageInfo, ctSuperGroup, 'MEU NOME', 'testando...');
    MessageInfo.Free;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  TestRichMode;
end;

procedure TForm4.Button3Click(Sender: TObject);
//var
//  LInput : TMemoryStream;
//var
//  MessageInfo: TMessageInfo;
begin
//  MessageInfo := TMessageInfo.Create;
//  MessageInfo.User := TUser(TEdit(Sender).Tag);
//  MessageInfo.MessageID := Random(128);
//  MessageInfo.ChatID := 1234;
//  MessageInfo.UserName := 'diegolacerdamenezes';
//  MessageInfo.FirstName := 'Ruan Diego';
//  MessageInfo.LastName := 'Lacerda Menezes';
//  MessageInfo.PhoneNumber := '+5521997196000';
//  MessageInfo.Message := TEdit(Sender).Text;
//  MessageInfo.MediaType := mtImagem;

//  if OpenDlg.Execute then
//  begin
//    try
//      LInput := TMemoryStream.Create;
//      Image1.Picture.LoadFromFile(OpenDlg.FileName);
//
//    //  MessageInfo.FileToSend.LoadFromFile(OpenDlg.FileName);
//
//      {$IFDEF VER340}
//        Image1.Picture.SaveToStream(LInput);
//      {$ELSE}
//        Image1.Picture.Bitmap.SaveToStream(LInput);
//      {$ENDIF}
//
//      {$IFDEF VER330}
//        Image1.Picture.SaveToStream(LInput);
//      {$ELSE}
//        Image1.Picture.Bitmap.SaveToStream(LInput);
//      {$ENDIF}
//
//      {$IFDEF VER320}
//        Image1.Picture.SaveToStream(LInput);
//      {$ELSE}
//        Image1.Picture.Bitmap.SaveToStream(LInput);
//      {$ENDIF}
//
//      {$IFDEF VER310}
//        Image1.Picture.Bitmap.SaveToStream(LInput);
//      {$ELSE}
//        Image1.Picture.Bitmap.SaveToStream(LInput);
//      {$ENDIF}
//
//      {$IFDEF VER300}
//        Image1.Picture.Bitmap.SaveToStream(LInput);
//      {$ELSE}
//        Image1.Picture.Bitmap.SaveToStream(LInput);
//      {$ENDIF}
//
//
//     // BotDAO.RegistrarCardapio(LInput);
//
//      LInput.Free;
//    //  showMessage('Cardápio cadastrado com sucesso!');
//
//      except on e:exception do
//      begin
//        showMessage('**** Falha ***** Tente outra imagem.');
//      end;
//    end;
//  end;
//
//
//    ChatControl1.Say(MessageInfo, ctSuperGroup, 'USER'+TEdit(Sender).Tag.ToString+' : ',TEdit(Sender).Text);
//    MessageInfo.Free;

end;

procedure TForm4.Edit2KeyPress(Sender: TObject; var Key: Char);
var
  MessageInfo: TMessageInfo;
begin
  MessageInfo := TMessageInfo.Create;
  MessageInfo.User := TUser(TEdit(Sender).Tag);
  MessageInfo.MessageID := Random(128);
  MessageInfo.ChatID := 1234;
  MessageInfo.UserName := 'diegolacerdamenezes';
  MessageInfo.FirstName := 'Ruan Diego';
  MessageInfo.LastName := 'Lacerda Menezes';
  MessageInfo.PhoneNumber := '+5521997196000';
  MessageInfo.Message := TEdit(Sender).Text;

  Assert(Sender is TEdit);
  if ord(Key) = VK_RETURN then
  begin              //TUser(TEdit(Sender).Tag) // MessageInfo
    //ChatControl1.Say(TMessageInfo(TUser(TEdit(Sender).Tag)), ctSuperGroup, 'USER'+TEdit(Sender).Tag.ToString+' : ',TEdit(Sender).Text);
    ChatControl1.SayUser(TUser(TEdit(Sender).Tag), ctSuperGroup, 'USER'+TEdit(Sender).Tag.ToString+' : ',TEdit(Sender).Text);
    Key := #0;
    TEdit(Sender).Clear;
    MessageInfo.Free;
  end;
end;

end.
