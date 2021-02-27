unit ChatWindow;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Math, StdCtrls, ExtCtrls, ChatControl, Vcl.ComCtrls, RichEdit,
  Vcl.Imaging.pngimage, SpeechBubble, Balloon, System.Generics.Collections;

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
    OpenDlg: TOpenDialog;
    Image1: TImage;
    Button4: TButton;
    Button5: TButton;
    Image2: TImage;
    btnTest: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
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
  MyChat: TChat;

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

procedure TForm4.btnTestClick(Sender: TObject);
var
  MyStream: TMemoryStream;
begin
  try
    MyStream := TMemoryStream.Create;
   // MyChat.FileToSend.SaveToStream(MyStream);
    MyStream.Position := 0;
    Image1.Picture.SaveToStream(MyStream);
  finally
    Image2.Picture.Bitmap.CanLoadFromStream(MyStream);

  end;
end;

procedure TForm4.Button1Click(Sender: TObject);
var
  i: integer;
var
  MyChat: TChat;
begin
  MyChat := TChat.Create;
  MyChat.User := TUser(TEdit(Sender).Tag);
  MyChat.Hora := FormatDateTime('HH:MM',Time);
  MyChat.MessageID := Random(128);
  MyChat.ChatID := 1234;
  MyChat.UserName := 'diegolacerdamenezes';
  MyChat.FirstName := 'Ruan Diego';
  MyChat.LastName := 'Lacerda Menezes';
  MyChat.PhoneNumber := '+5521997196000';
  MyChat.Message := TEdit(Sender).Text;


  ChatControl1.Strings.Clear;
  for i := 0 to StrToInt(LabeledEdit1.Text) - 1 do
                     //TUser(Random(2))
    ChatControl1.Say(MyChat, ctSuperGroup);
    MyChat.Free;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
  TestRichMode;
end;

procedure TForm4.Button3Click(Sender: TObject);
begin

  if OpenDlg.Execute then
  begin
    try
      Image1.Picture.LoadFromFile(OpenDlg.FileName);

      try
        MyChat := Nil;
        MyChat := TChat.Create; //instancia uma nova mensagem
        MyChat.MediaType := mtLink;
        MyChat.Hora := FormatDateTime('HH:MM',Time);
        MyChat.User := User1;
        MyChat.MessageID := Random(128);
        MyChat.ChatID := 1234;
        MyChat.Message := Edit1.Text;
        MyChat.UserName := 'diegolacerdamenezes';
        MyChat.FirstName := 'Ruan Diego';
        MyChat.LastName := 'Lacerda Menezes';
        MyChat.PhoneNumber := '+5521997196000';
        MyChat.FileToSend := Image1.Picture.Graphic;

      finally
        //Exemplo de uso de enviopassando o object MenssageInfo com os dados da Mensagens
        ChatControl1.SayFile(MyChat, ctSuperGroup);
      end;

    except on e:exception do
      begin
        showMessage('**** Falha ***** Tente outra imagem.'+#10#13+e.Message);
      end;

    end;
  end;

end;

procedure TForm4.Button5Click(Sender: TObject);
begin

  if OpenDlg.Execute then
  begin

    try
      Image1.Picture.LoadFromFile(OpenDlg.FileName);
      try
        MyChat := Nil;
        MyChat := TChat.Create; //instancia uma nova mensagem
        MyChat.MediaType := mtImagem;
        MyChat.Hora := FormatDateTime('HH:MM',Time);
        MyChat.User := User2;
        MyChat.MessageID := Random(128);
        MyChat.ChatID := 1234;
        MyChat.Message := Edit2.Text;
        MyChat.UserName := 'Bot';
        MyChat.FirstName := 'ChatBot';
        MyChat.LastName := 'LMCodee';
        MyChat.PhoneNumber := '+5521123456780';
        MyChat.FileToSend := Image1.Picture.Graphic;

      finally
        //Exemplo de uso de enviopassando o object MenssageInfo com os dados da Mensagens
        ChatControl1.SayFile(MyChat, ctSuperGroup);
      end;

    except on e:exception do
      begin
        showMessage('**** Falha ***** Tente outra imagem.'+#10#13+e.Message);
      end;

    end;
  end;

end;

procedure TForm4.Edit2KeyPress(Sender: TObject; var Key: Char);
var
  Txt : String;
begin
  if TEdit(Sender).Text <> '' then
  Begin
    Assert(Sender is TEdit);
    if ord(Key) = VK_RETURN then
    begin

      try

        MyChat := Nil;
        MyChat := TChat.Create; //instancia uma nova mensagem

        Txt := TEdit(Sender).Text;
        if Txt.ToLower.Contains('http://') or
          Txt.ToLower.Contains('www.') and
          Txt.ToLower.Contains('.com') then
        Begin
          MyChat.MediaType := mtLink;
        End
        Else
          MyChat.MediaType := mtTexto;

        MyChat.Hora := FormatDateTime('HH:MM',Time);
        MyChat.User := TUser(TEdit(Sender).Tag);
        MyChat.MessageID := Random(128);
        MyChat.ChatID := 1234;
        MyChat.Message := TEdit(Sender).Text;

        if TEdit(Sender).Tag = 0 then
        Begin
          MyChat.UserName := 'diegolacerdamenezes';
          MyChat.FirstName := 'Ruan Diego';
          MyChat.LastName := 'Lacerda Menezes';
          MyChat.PhoneNumber := '+5521997196000';
        End
        Else
        Begin
          MyChat.UserName := 'LMCODelivery';
          MyChat.FirstName := 'ChatBot';
          MyChat.LastName := 'LMCodee';
          MyChat.PhoneNumber := '+5521123456780';
        End;

      finally
        //Exemplo de uso de enviopassando o object MenssageInfo com os dados da Mensagens
        ChatControl1.Say(MyChat, ctSuperGroup);
      end;

      //Exemplo de uso de envio passando o Codigo do Usuario
  //    ChatControl1.SayUser(TUser(TEdit(Sender).Tag), ctRegularGroup, 'USER'+TEdit(Sender).Tag.ToString+' : ',TEdit(Sender).Text);
      Key := #0;
      TEdit(Sender).Clear;

    end;
  End;

end;

end.
