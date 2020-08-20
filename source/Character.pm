#===================================================================
#        キャラステータス解析パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;


require "./source/lib/IO.pm";
require "./source/lib/time.pm";

require "./source/chara/Name.pm";
require "./source/chara/Status.pm";
require "./source/chara/Production.pm";
require "./source/chara/Embryo.pm";
require "./source/chara/Item.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Character;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class        = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
    ResultNo      => "",
    GenerateNo    => "",
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;

    #インスタンス作成
    if (ConstData::EXE_CHARA_NAME)       { $self->{DataHandlers}{Name}       = Name->new();}
    if (ConstData::EXE_CHARA_STATUS)     { $self->{DataHandlers}{Status}     = Status->new();}
    if (ConstData::EXE_CHARA_PRODUCTION) { $self->{DataHandlers}{Production} = Production->new();}
    if (ConstData::EXE_CHARA_EMBRYO)     { $self->{DataHandlers}{Embryo}     = Embryo->new();}
    if (ConstData::EXE_CHARA_ITEM)       { $self->{DataHandlers}{Item}       = Item->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から詳細データファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self = shift;

    print "read files...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './data/utf/result' . $self->{ResultNo};
    $directory .= ($self->{GenerateNo} > 0) ? '_' . $self->{GenerateNo} . '/k' : '/k';
    if (ConstData::EXE_ALLRESULT) {
        #結果全解析
        $end = GetMaxFileNo($directory,"k");
    } else {
        #指定範囲解析
        $start = ConstData::FLAGMENT_START;
        $end   = ConstData::FLAGMENT_END;
    }

    print "$directory\n";

    print "$start to $end\n";

    for (my $e_no=$start; $e_no<=$end; $e_no++) {
        if ($e_no % 10 == 0) {print $e_no . "\n"};

        $self->ParsePage($directory."/k".$e_no.".html",$e_no);
    }
    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParsePage{
    my $self      = shift;
    my $file_name = shift;
    my $e_no      = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::FileRead($file_name);

    if (!$content) { return;}

    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $link_data_nodes = &GetNode::GetNode_Tag_Attr("a", "name", "DATA",     \$tree);
    my $table_charachter_data_node = $$link_data_nodes[0]->parent->parent->parent->right->right->right;
    my $table_PD2_nodes = &GetNode::GetNode_Tag_Attr("table", "class", "PD2", \$table_charachter_data_node);

    # データリスト取得
    if (exists($self->{DataHandlers}{Name}))       {$self->{DataHandlers}{Name}->GetData       ($e_no, $table_charachter_data_node)};
    if (exists($self->{DataHandlers}{Status}))     {$self->{DataHandlers}{Status}->GetData     ($e_no, $table_charachter_data_node)};
    if (exists($self->{DataHandlers}{Production})) {$self->{DataHandlers}{Production}->GetData ($e_no, $table_charachter_data_node)};
    if (exists($self->{DataHandlers}{Embryo}))     {$self->{DataHandlers}{Embryo}->GetData     ($e_no, $table_PD2_nodes)};
    if (exists($self->{DataHandlers}{Item}))       {$self->{DataHandlers}{Item}->GetData       ($e_no, $table_PD2_nodes)};

    $tree = $tree->delete;
}

#-----------------------------------#
#       最大ファイル番号を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetMaxFileNo{
    my $directory = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html");

    my $max= 0;
    foreach (@fileList) {
        $_ =~ /$prefix(\d+).html/;
        if ($max < $1) {$max = $1;}
    }
    return $max
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output{
    my $self = shift;

    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }

    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }

    return;
}

1;
