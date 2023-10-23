unit uMain;

interface

uses System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
     Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, Vcl.StdCtrls, Vcl.Buttons,
     System.Threading, jpeg, RESTRequest4D,
     DataSet.Serialize.Adapter.RESTRequest4D,
     System.Json, System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent, REST.Client, Data.Bind.Components,
     Data.Bind.ObjectScope, Vcl.WinXCtrls, Vcl.ComCtrls, Vcl.ExtCtrls;


type
  TForm1 = class(TForm)
    Panel2: TPanel;
    rdOpcoes: TRadioGroup;
    Panel3: TPanel;
    Panel4: TPanel;
    mmStatus: TMemo;
    mmResultJson: TMemo;
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
    lblEstrelas: TLabel;
    lblwatchers: TLabel;
    lblbranch: TLabel;
    lblVisibilidade: TLabel;
    lblHomePage: TLabel;
    procedure btngetClick(Sender: TObject);
    procedure rdOpcoesClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
  private
    { Private declarations }
     procedure BuscaDadosAPI(aTipo :Integer; aPesquisa:string);
     procedure ObterLista;
     procedure GetUserParametros(sUrl:string);
     procedure GetAvatar;

  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  iOpcaoMenu :integer;
  Resp,RespFull : IResponse;

const GITHUB_API_BASE_URL = 'https://api.github.com';
      aToken = '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';

implementation

{$R *.dfm}

procedure TForm1.FormShow(Sender: TObject);
begin
  lblEstrelas.caption     := 'Estrelas.....: ';
  lblwatchers.caption     := 'Watchers.....: ';
  lblbranch.caption       := 'Branch.......: ';
  lblVisibilidade.caption := 'Visiabilidade: ';
  lblHomePage.caption     := 'Web/URL......: ';

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

     TThread.Synchronize(TThread.CurrentThread,
     procedure
     begin
       try
         BuscaDadosAPI( ActiveControl.Tag,  trim(edtPesquisa.Text) );

         ActivityIndicator1.visible:=false;
         ActivityIndicator1.Animate:=false;
         ActivityIndicator1.Enabled:=false;

       except
         on E: Exception do
         begin
           ActivityIndicator1.visible:=false;
           mmResultJson.Clear;
           mmResultJson.Lines.add(E.Message);
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
    0 : sURLPesquisa := Format('/search/users?q=%s', [aPesquisa]);
    1 : sURLPesquisa := Format('/search/repositories?q=%s', [aPesquisa]);
    2 : sURLPesquisa := Format('/search/users?q=%s&type=org', [aPesquisa]);
  end;

  if aTipo<>1 then
     sURLPesquisa:= '/users/' + aPesquisa;

  mmStatus.Lines.add( 'Pesquisar por: ' + rdOpcoes.Items[rdOpcoes.ItemIndex] );
  mmStatus.Lines.add( 'URL..........: ' + GITHUB_API_BASE_URL + sURLPesquisa );
  mmStatus.Refresh;

  //https://api.github.com/users/Rontechti
  TRequest.New.Token('Bearer ' + aToken );

   case aTipo of
      1 : Resp := TRequest.New.BaseURL( GITHUB_API_BASE_URL )
                              .Resource( sURLPesquisa )
                              .Accept('application/json')
                              .RaiseExceptionOn500(True)
                              .Get;

      2 : Resp := TRequest.New.BaseURL( GITHUB_API_BASE_URL )
                              .Resource( sURLPesquisa )
                              .Accept('application/json' )
                              .AddBody('{"email":"email_teste@gmail.com"}')
                              .Post;


      3 : Resp := TRequest.New.BaseURL( GITHUB_API_BASE_URL )
                              .Resource( sURLPesquisa )
                              .Accept('application/json' )
                              .AddBody('{"email":"email_teste@gmail.com"}')
                              .Put;

      4 : Resp := TRequest.New.BaseURL( GITHUB_API_BASE_URL )
                              .Resource( sURLPesquisa )
                              .Accept('application/json')
                              .Delete;

    end;

  if Resp.StatusCode = 200 then
  begin
    pnlResultado.Caption := 'Servidor conectado com exito';
    pnlResultado.Color   := clLime;

    mmResultJson.Lines.add( Resp.Content );

    if Length(trim(Resp.Content))>0  then
      ObterLista;

  end else
  begin
    pnlResultado.Caption := 'Erro no servidor: ' + Resp.StatusCode.ToString;
    pnlResultado.Color   := clGray;
    ShowMessage('Falha na chamada da API ');
  end;

  pnlResultado.Refresh;

end;

procedure TForm1.ObterLista;
var
  jSonArr : TJSONArray;
  aSon : string;
  Json : TJSONObject;
  i  : integer;
  sLogin, sAvatar, sURL, sUserParametros : string;
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
      if iOpcaoMenu = 1 then
      begin
        sLogin    := jSonArr.get(i).GetValue<string>('owner.login') ;
        sAvatar   := jSonArr.get(i).GetValue<string>('owner.avatar_url') ;
        sURL      := jSonArr.get(i).GetValue<string>('owner.url') ;
      end else
      begin
        sLogin  := jSonArr.get(i).GetValue<string>('login') ;
        sAvatar := jSonArr.get(i).GetValue<string>('avatar_url') ;
        sURL    := jSonArr.get(i).GetValue<string>('url') ;
      end;

      sUserParametros := Format('https://api.github.com/users/%s/starred', [sLogin] );

      mmItensJson.Lines.Add( Format('Usuário..: %s ', [sLogin] ));
      mmItensJson.Lines.Add( 'URL......: ' + sURL );

      Item := ListView1.Items.Add;
      Item.Caption := sLogin;
      Item.SubItems.Add( sAvatar );
      Item.SubItems.Add( sUserParametros );

    end;
    Json.DisposeOf;
end;


procedure TForm1.ListView1Click(Sender: TObject);
begin
  lblEstrelas.caption     := 'Estrelas....: ';
  lblwatchers.caption     := 'Watchers....: ';
  lblbranch.caption       := 'Branch......: ';
  lblVisibilidade.caption := 'Visibilidade: ';
  lblHomePage.caption     := 'Web/URL.....: ';

  TThread.Synchronize(TThread.CurrentThread,
     procedure
     begin
      ActivityIndicator1.visible:=true;
      ActivityIndicator1.Animate:=True;
      ActivityIndicator1.Enabled:=true;
    end);

   TTask.Run(procedure
   begin
     TThread.Synchronize(TThread.CurrentThread,
     procedure
     begin
        GetUserParametros( ListView1.Items[ListView1.ItemIndex].SubItems[1] );
        GetAvatar;

        ActivityIndicator1.visible:=false;
        ActivityIndicator1.Animate:=false;
        ActivityIndicator1.Enabled:=false;
     end);
   end);

end;

procedure TForm1.GetUserParametros(sUrl:string);
var
  jSonArr : TJSONArray;
  aSon : string;
  Json : TJSONObject;
  i  : integer;
begin
  if Length(trim(sUrl)) = 0 then
    exit;

   RespFull := TRequest.New.BaseURL( sURL )
                           .Accept('application/json')
                           .Get;
   mmResultJson.Clear;
   mmResultJson.Lines.Add( RespFull.Content);

  if RespFull.StatusCode = 200 then
  begin
    jSonArr    := TJSONObject.ParseJSONValue( TEncoding.UTF8.GetBytes( mmResultJson.Lines.Text ), 0) as TJSONArray;

    if jSonArr.Count = 0 then
      exit;

    for i := 0 to jSonArr.size -1 do
    begin
      lblEstrelas.caption     := 'Estrelas....: ' + jSonArr.get(i).GetValue<string>('stargazers_count');
      lblwatchers.caption     := 'Watchers....: ' + jSonArr.get(i).GetValue<string>('watchers');
      lblbranch.caption       := 'Branch......: ' + jSonArr.get(i).GetValue<string>('default_branch');
      lblVisibilidade.caption := 'Visibilidade: ' + jSonArr.get(i).GetValue<string>('visibility');
      lblHomePage.caption     := 'Web/URL.....: ' + jSonArr.get(i).GetValue<string>('homepage');
    end;
  end;

end;


procedure TForm1.GetAvatar;
var
  Jpeg: TJpegImage;
  Strm: TMemoryStream;
begin
  Image1.Picture := nil;

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


