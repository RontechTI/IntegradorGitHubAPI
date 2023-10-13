unit uMain;

interface

uses System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
     Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, Vcl.StdCtrls, Vcl.Buttons,
     System.Json, System.Net.URLClient, System.Net.HTTPCLient,System.Threading,jpeg,
     System.Net.HTTPCLientComponent, Vcl.ExtCtrls, Vcl.ComCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
     FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, Vcl.WinXCtrls, Data.DB, FireDAC.Comp.DataSet,
     FireDAC.Comp.Client, REST.Response.Adapter, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope ;

type
  TForm1 = class(TForm)
    Panel2: TPanel;
    rdOpcoes: TRadioGroup;
    Panel3: TPanel;
    Panel4: TPanel;
    mmStatus: TMemo;
    mmResultJson: TMemo;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    ActivityIndicator1: TActivityIndicator;
    pnlResultado: TPanel;
    Label1: TLabel;
    edtPesquisa: TEdit;
    Panel1: TPanel;
    btnget: TBitBtn;
    BitBtn2: TBitBtn;
    btnDelete: TBitBtn;
    BitBtn1: TBitBtn;
    mmItensJson: TMemo;
    Image1: TImage;
    Label2: TLabel;
    ListView1: TListView;
    NetHTTPClient1: TNetHTTPClient;
    Label3: TLabel;
    Panel5: TPanel;
    star5: TSpeedButton;
    star4: TSpeedButton;
    star3: TSpeedButton;
    star2: TSpeedButton;
    star1: TSpeedButton;
    procedure btngetClick(Sender: TObject);
    procedure rdOpcoesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
  private
    { Private declarations }
     procedure BuscaDadosAPI(aTipo :Integer; aPesquisa:string);
     procedure ObterLista;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  iOpcaoMenu, RespCode : Integer;


const GITHUB_API_BASE_URL = 'https://api.github.com/search/';

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
begin
  mmStatus.Clear;
  mmResultJson.Clear;
  mmItensJson.Clear;
end;

procedure TForm1.rdOpcoesClick(Sender: TObject);
begin
  case rdOpcoes.ItemIndex of
    0 : edtPesquisa.Text := 'Rontechti';
    1 : edtPesquisa.Text := 'users';
    2 : edtPesquisa.Text := '3ch023';
  end;
end;

procedure TForm1.btngetClick(Sender: TObject);
begin
  mmStatus.Clear;
  mmResultJson.Clear;
  mmItensJson.Clear;

  star1.Enabled := false;
    star2.Enabled := false;
      star3.Enabled := false;
        star4.Enabled := false;
          star5.Enabled := false;

  if rdOpcoes.ItemIndex = -1 then
  begin
    ShowMessage( 'Informe uma opção de pesquisa válida');
    exit;
  end;

  if Length(Trim(edtPesquisa.Text))=0 then
  begin
    ShowMessage( 'Informe um conteúdo válido para a pesquisa');
    edtPesquisa.SetFocus;
    exit;
  end;

  TThread.Synchronize(TThread.CurrentThread,
     procedure
     begin
      ActivityIndicator1.visible:=true;
      ActivityIndicator1.Animate:=True;
      ActivityIndicator1.Enabled:=true;
    end);

   TTask.Run(procedure
   begin
     Sleep(2000);
     TThread.Synchronize(TThread.CurrentThread,
     procedure
     begin
       try
         //Response :=
         BuscaDadosAPI( ActiveControl.Tag,
                               trim(edtPesquisa.Text) );

         ActivityIndicator1.visible:=false;
         ActivityIndicator1.Animate:=false;
         ActivityIndicator1.Enabled:=false;

       except
         on E: Exception do
         begin
           ActivityIndicator1.visible:=false;
           mmStatus.Clear;
           mmStatus.Lines.add(E.Message);
           if RespCode <> 200 then
             ShowMessage('Erro na chamada da API ao servidor web.');

         end;
       end;
     end);
   end);
end;

procedure TForm1.BuscaDadosAPI(aTipo :Integer; aPesquisa:string);
var
  sURLPesquisa : string;
begin
  iOpcaoMenu := rdOpcoes.ItemIndex;

  case iOpcaoMenu of
    0 : sURLPesquisa := Format('%susers?q=%s', [GITHUB_API_BASE_URL, aPesquisa]);
    1 : sURLPesquisa := Format('%srepositories?q=%s', [GITHUB_API_BASE_URL, aPesquisa]);
    2 : sURLPesquisa := Format('%susers?q=%s&type=org', [GITHUB_API_BASE_URL, aPesquisa]);
  end;

  case aTipo of
    1 : RESTRequest1.Method := rmGet;   //TRESTRequestMethod.rmPOST;
    2 : RESTRequest1.Method := rmPOST;
    3 : RESTRequest1.Method := rmPUT;
    4 : RESTRequest1.Method := rmDELETE;
  end;

  RESTClient1.BaseURL                               := sURLPesquisa;
  RESTClient1.RaiseExceptionOn500                   := true;

  try
    RESTRequest1.Execute;
  except
    pnlResultado.Caption := 'Erro de Conexão ao Servidor';
  end;

  RespCode := RESTResponse1.StatusCode;

  mmStatus.Lines.add( 'Pesquisar por: ' + rdOpcoes.Items[rdOpcoes.ItemIndex] );
  mmStatus.Lines.add( 'URL..........: ' + sURLPesquisa );

  // Exibir os resultados
  if RespCode = 200 then
  begin
    pnlResultado.Caption := 'Servidor conectado com exito';
    pnlResultado.Color   := clLime;

    mmResultJson.Lines.add( RESTResponse1.JSONText );

    ObterLista;

  end else
  begin
    pnlResultado.Caption := 'Erro no servidor: ' + RespCode.ToString;
    pnlResultado.Color   := clGray
  end;

  pnlResultado.Refresh;

end;

procedure TForm1.ObterLista;
var
  jSonArr : TJSONArray;
  aSon : string;
  Json : TJSONObject;
  i  : integer;
  sScore,sLogin, sAvatar, sURL : string;
  Item: TListItem;
begin
    json    := TJSONObject.ParseJSONValue( TEncoding.UTF8.GetBytes( mmResultJson.Lines.Text ), 0) as TJSONObject;

    jSonArr := Json.GetValue<TJSONArray>('items');

    mmItensJson.Lines.Add( '-------------------------------------');
    mmItensJson.Lines.Add( '            Lista de Dados');
    mmItensJson.Lines.Add( '-------------------------------------');

    ListView1.Clear;

    if jSonArr.Count = 0 then
    begin
      mmItensJson.Lines.Add( format(' "%s" não localizado no repositório.', [edtPesquisa.Text]) );
      exit;
    end;

    for i := 0 to jSonArr.size -1 do
    begin
      sScore := '';

      if iOpcaoMenu = 1 then
      begin
        sLogin  := jSonArr.get(i).GetValue<string>('owner.login') ;
        sAvatar := jSonArr.get(i).GetValue<string>('owner.avatar_url') ;
        sURL    := jSonArr.get(i).GetValue<string>('owner.url') ;
        //sScore  := jSonArr.get(i).GetValue<string>('owner.score') ;
      end else
      begin
        sLogin  := jSonArr.get(i).GetValue<string>('login') ;
        sAvatar := jSonArr.get(i).GetValue<string>('avatar_url') ;
        sURL    := jSonArr.get(i).GetValue<string>('url') ;
        sScore  := jSonArr.get(i).GetValue<string>('score') ;
      end;

      mmItensJson.Lines.Add( Format('Usuário..: %s -> %s', [sLogin, sScore] ));
      mmItensJson.Lines.Add( 'URL......: ' + sURL );

      Item := ListView1.Items.Add;
      Item.Caption := sLogin;
      Item.SubItems.Add( sAvatar );

    end;
    Json.DisposeOf;
end;

procedure TForm1.ListView1Click(Sender: TObject);
var
  Jpeg: TJpegImage;
  Strm: TMemoryStream;
begin
  Image1.Picture := Nil;

  star1.Enabled := false;
    star2.Enabled := false;
      star3.Enabled := false;
        star4.Enabled := false;
          star5.Enabled := false;

  try
    Screen.Cursor := crHourGlass;
    Jpeg := TJpegImage.Create;
    Strm := TMemoryStream.Create;
    try
      NetHTTPClient1.Get( ListView1.Items[ListView1.ItemIndex].SubItems[0] , Strm);
      if (Strm.Size > 0) then
      begin
        Strm.Position := 0;
        Jpeg.LoadFromStream(Strm);
        Image1.Picture.Assign(Jpeg);
      end;
    finally
      Label3.Caption := ListView1.Items[ListView1.ItemIndex].Caption;
      Strm.DisposeOf;
      Jpeg.DisposeOf;
      Screen.Cursor := crDefault;
    end;
  except
    Label3.Caption := '';
  end;

end;

end.

