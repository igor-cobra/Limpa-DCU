object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Limpa DCU'
  ClientHeight = 442
  ClientWidth = 628
  Color = 16446693
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object stsRodape: TStatusBar
    Left = 0
    Top = 423
    Width = 628
    Height = 19
    Panels = <
      item
        Text = 'Vers'#227'o:'
        Width = 150
      end
      item
        Width = 50
      end>
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 628
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblModoEscuro: TLabel
      Left = 77
      Top = 7
      Width = 70
      Height = 15
      Caption = 'Modo Escuro'
    end
    object btnLimparDcu: TButton
      Left = 549
      Top = 34
      Width = 75
      Height = 25
      Caption = '&Limpar DCUs'
      TabOrder = 0
      OnClick = btnLimparDcuClick
    end
    object btnCadastrar: TButton
      Left = 408
      Top = 3
      Width = 105
      Height = 25
      Caption = '&Cadastrar Projeto'
      TabOrder = 1
      TabStop = False
      OnClick = btnCadastrarClick
    end
    object btnExcluirProjeto: TButton
      Left = 519
      Top = 3
      Width = 105
      Height = 25
      Caption = '&Excluir Projeto'
      TabOrder = 2
      TabStop = False
      OnClick = btnExcluirProjetoClick
    end
    object tlgModoEscuro: TToggleSwitch
      Left = 15
      Top = 6
      Width = 56
      Height = 18
      ShowStateCaption = False
      TabOrder = 3
      OnClick = tlgModoEscuroClick
    end
  end
  object dbgListaProj: TDBGrid
    Left = 0
    Top = 65
    Width = 628
    Height = 191
    Align = alClient
    DataSource = dsListaProj
    Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
    ReadOnly = True
    TabOrder = 2
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -12
    TitleFont.Name = 'Segoe UI'
    TitleFont.Style = []
    OnCellClick = dbgListaProjCellClick
    OnDrawColumnCell = dbgListaProjDrawColumnCell
    OnTitleClick = dbgListaProjTitleClick
    Columns = <
      item
        Expanded = False
        FieldName = 'SEL'
        Title.Caption = 'Sel'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -12
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Width = 25
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'IDPROJETO'
        Title.Caption = 'C'#243'digo'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -12
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'NOMEPROJ'
        Title.Caption = 'Projeto'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -12
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Width = 150
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'CAMINHOPROJ'
        Title.Caption = 'Caminho'
        Title.Font.Charset = DEFAULT_CHARSET
        Title.Font.Color = clWindowText
        Title.Font.Height = -12
        Title.Font.Name = 'Segoe UI'
        Title.Font.Style = [fsBold]
        Width = 350
        Visible = True
      end>
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 256
    Width = 628
    Height = 167
    Align = alBottom
    Caption = ''
    TabOrder = 3
    object lblLogRegistros: TLabel
      Left = 1
      Top = 1
      Width = 626
      Height = 21
      Align = alTop
      Caption = 'Log de registros'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 121
    end
    object mmoLog: TMemo
      Left = 1
      Top = 22
      Width = 626
      Height = 144
      TabStop = False
      Align = alClient
      ReadOnly = True
      ScrollBars = ssVertical
      TabOrder = 0
    end
  end
  object dsListaProj: TDataSource
    DataSet = cdsListaProj
    Left = 576
    Top = 80
  end
  object cdsListaProj: TFDMemTable
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    ResourceOptions.AssignedValues = [rvSilentMode]
    ResourceOptions.SilentMode = True
    UpdateOptions.AssignedValues = [uvCheckRequired, uvAutoCommitUpdates]
    UpdateOptions.CheckRequired = False
    UpdateOptions.AutoCommitUpdates = True
    Left = 512
    Top = 80
    object cdsListaProjSEL: TBooleanField
      FieldName = 'SEL'
    end
    object cdsListaProjIDPROJETO: TIntegerField
      FieldName = 'IDPROJETO'
    end
    object cdsListaProjNOMEPROJ: TWideStringField
      FieldName = 'NOMEPROJ'
      Size = 100
    end
    object cdsListaProjCAMINHOPROJ: TWideStringField
      FieldName = 'CAMINHOPROJ'
      Size = 500
    end
  end
end
