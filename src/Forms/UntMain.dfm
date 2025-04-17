object FrmMain: TFrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
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
  OnCreate = FormCreate
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
        Text = 'Vers'#227'o APL: 1.0.0.0'
        Width = 50
      end>
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 628
    Height = 177
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object dbgListaProj: TDBGrid
      Left = 0
      Top = 0
      Width = 628
      Height = 145
      Align = alTop
      DataSource = dsListaProj
      Options = [dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ReadOnly = True
      TabOrder = 0
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
    object btnLimparDcu: TButton
      Left = 544
      Top = 149
      Width = 75
      Height = 25
      Caption = '&Limpar Dcu'#39's'
      TabOrder = 1
      OnClick = btnLimparDcuClick
    end
    object btnCadastrar: TButton
      Left = 8
      Top = 149
      Width = 105
      Height = 25
      Caption = '&Cadastrar Projeto'
      TabOrder = 2
      TabStop = False
      OnClick = btnCadastrarClick
    end
    object btnExcluirProjeto: TButton
      Left = 119
      Top = 149
      Width = 105
      Height = 25
      Caption = '&Excluir Projeto'
      TabOrder = 3
      TabStop = False
      OnClick = btnExcluirProjetoClick
    end
  end
  object mmoLog: TMemo
    Left = 0
    Top = 177
    Width = 628
    Height = 246
    TabStop = False
    Align = alClient
    Lines.Strings = (
      'mmoLog')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
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
    object cdsListaProjNOMEPROJ: TStringField
      FieldName = 'NOMEPROJ'
      Size = 100
    end
    object cdsListaProjCAMINHOPROJ: TStringField
      FieldName = 'CAMINHOPROJ'
      Size = 500
    end
  end
end
