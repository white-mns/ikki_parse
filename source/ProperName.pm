#===================================================================
#        固有名詞管理パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;

require "./source/data/StoreProperName.pm";
require "./source/data/StoreProperData.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package ProperName;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class        = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;

    #インスタンス作成
    $self->{DataHandlers}{ProperName} = StoreProperName->new();
    $self->{DataHandlers}{EmbryoName} = StoreProperName->new();
    $self->{DataHandlers}{SkillData}  = StoreProperData->new();
    $self->{DataHandlers}{AreaData}   = StoreProperData->new();

    #他パッケージへの引き渡し用インスタンス
    $self->{CommonDatas}{ProperName} = $self->{DataHandlers}{ProperName};
    $self->{CommonDatas}{EmbryoName} = $self->{DataHandlers}{EmbryoName};
    $self->{CommonDatas}{SkillData}  = $self->{DataHandlers}{SkillData};
    $self->{CommonDatas}{AreaData}   = $self->{DataHandlers}{AreaData};

    my $header_list = "";
    my $output_file = "";

    # 固有名詞の初期化
    $header_list = [
                "proper_id",
                "name",
    ];
    $output_file = "./output/data/". "proper_name" . ".csv";
    $self->{DataHandlers}{ProperName}->Init($header_list, $output_file," ");

    # 固有名詞の初期化
    $header_list = [
                "embryo_id",
                "name",
    ];
    $output_file = "./output/data/". "embryo_name" . ".csv";
    $self->{DataHandlers}{EmbryoName}->Init($header_list, $output_file," ");

    # スキル情報の初期化
    $header_list = [
                "skill_id",
                "name",
                "embryo_id",
                "is_physics",
                "lv",
                "sp",
                "gift_id",
                "gp",
    ];
    $output_file = "./output/data/". "skill_data" . ".csv";
    $self->{DataHandlers}{SkillData}->Init($header_list, $output_file, [" ", 0, 0, 0, 0, 0, 0]);

    # エリア情報の初期化
    $header_list = [
                "area_id",
                "name",
                "level",
    ];
    $output_file = "./output/data/". "area_data" . ".csv";
    $self->{DataHandlers}{AreaData}->Init($header_list, $output_file, [" ", 0]);


    return;
}

#-----------------------------------#
#   このパッケージでデータ解析はしない
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;
    return ;
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
