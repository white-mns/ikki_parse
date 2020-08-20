#===================================================================
#        新出スキル取得パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package NewSkill;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{ResultNo}, $self->{GenerateNo}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{NewSkill} = StoreData->new();
    $self->{Datas}{AllSkill} = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "skill_id",
    ];

    $self->{Datas}{NewSkill}->Init($header_list);
    $self->{Datas}{AllSkill}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{NewSkill}->SetOutputName( "./output/new/skill_"     . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{AllSkill}->SetOutputName( "./output/new/all_skill_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    
    $self->ReadLastNewData();

    return;
}

#-----------------------------------#
#    既存データを読み込む
#-----------------------------------#
sub ReadLastNewData(){
    my $self      = shift;
    
    my $file_name = "";
    # 前回結果の確定版ファイルを探索
    $file_name = "./output/new/all_skill_" . sprintf("%d", ($self->{ResultNo} - 1)) . "_0.csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $new_item_use_datas = []; 
        @$new_item_use_datas   = split(ConstData::SPLIT, $data_set);
        my $skill_id = $$new_item_use_datas[2];
        if(!exists($self->{AllSkill}{$skill_id})){
            $self->{AllSkill}{$skill_id} = [$self->{ResultNo}, $self->{GenerateNo}, $skill_id];
        }
    }

    return;
}

#-----------------------------------#
#    新出スキルの判定と記録
#------------------------------------
#    引数｜スキルID
#-----------------------------------#
sub RecordNewSkillData{
    my $self    = shift;
    my $skill_id = shift;

    if (exists($self->{AllSkill}{$skill_id})) {return;}

    $self->{Datas}{NewSkill}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $skill_id) ));

    $self->{AllSkill}{$skill_id} = [$self->{ResultNo}, $self->{GenerateNo}, $skill_id];

    return;
}
#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;

    # 新出データ判定用の既出情報の書き出し
    foreach my $id (sort{$a cmp $b} keys %{ $self->{AllSkill} } ) {
        $self->{Datas}{AllSkill}->AddData(join(ConstData::SPLIT, @{ $self->{AllSkill}{$id} }));
    }
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
