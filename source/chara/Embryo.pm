#===================================================================
#        所持エンブリオ・所持スキル取得パッケージ
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
package Embryo;

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
    $self->{Datas}{Embryo}  = StoreData->new();
    $self->{Datas}{Skill}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "order",
                "embryo_id",
                "is_physics",
                "lv",
    ];

    $self->{Datas}{Embryo}->Init($header_list);

    $header_list = [
                "result_no",
                "generate_no",
                "e_no",
                "order",
                "skill_id",
                "gift_open",
    ];

    $self->{Datas}{Skill}->Init($header_list);
   
    #出力ファイル設定
    $self->{Datas}{Embryo}->SetOutputName( "./output/chara/embryo_" . $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    $self->{Datas}{Skill}->SetOutputName ( "./output/chara/skill_" .  $self->{ResultNo} . "_" . $self->{GenerateNo} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,キャラクターデータノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $table_PD2_nodes = shift;
    
    $self->{ENo} = $e_no;

    $self->GetEmbryoData($table_PD2_nodes);
    
    return;
}

#-----------------------------------#
#    所持エンブリオデータ取得
#------------------------------------
#    引数｜キャラクターデータノード
#-----------------------------------#
sub GetEmbryoData{
    my $self  = shift;
    my $table_PD2_nodes = shift;

    my $embryo_title_node = "";

    foreach my $node (@$table_PD2_nodes) {
       if ($node->as_text eq "エンブリオ") {
           $embryo_title_node = $node;
       }
    }

    if ($embryo_title_node !~ /HASH/) {return;}

    my $order = 0;

    my @embryo_right_nodes = $embryo_title_node->right;


    foreach my $embryo_right_node (@embryo_right_nodes) {
        if ($embryo_right_node->attr("class") && $embryo_right_node->attr("class") eq "PD2") {last;}

        my ($embryo_id, $is_physics, $lv) = (0, -1, -1);
        
        my $td_nodes = &GetNode::GetNode_Tag("td", \$embryo_right_node);

        if (!$$td_nodes[0] || $$td_nodes[0] !~ /HASH/ || 
            !$$td_nodes[0]->attr("class") || $$td_nodes[0]->attr("class") ne "Y4i" || 
            !$$td_nodes[0]->as_text || $$td_nodes[0]->as_text !~ /\d+/ || 
            !$$td_nodes[1]->as_text || $$td_nodes[1]->as_text !~ /Lv\./) { next;}

        my $order = $$td_nodes[0]->as_text; 
        
        my $a_nodes = &GetNode::GetNode_Tag("a", \$$td_nodes[1]);
        my @a_child_nodes = $$a_nodes[0]->content_list;
        $is_physics = ($a_child_nodes[0]->attr("src") =~ /eb/) ? 1 : 0;
        
        if ($a_child_nodes[1]->as_text =~ /(.+) Lv.(\d+)/) {
            $embryo_id = $self->{CommonDatas}{EmbryoName}->GetOrAddId($1);
            $lv = $2;
        }

        $self->{Datas}{Embryo}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $order, $embryo_id, $is_physics, $lv) ));
        my $div_Enb_node = $embryo_right_node->right;
        $self->GetSkillData($div_Enb_node, $order, $embryo_id, $is_physics);

    }
    return;
}

#-----------------------------------#
#    所持スキルデータ取得
#------------------------------------
#    引数｜スキルデータノード
#-----------------------------------#
sub GetSkillData{
    my $self  = shift;
    my $div_Enb_node = shift;
    my $order = shift;
    my $embryo_id  = shift;
    my $is_physics = shift;

    if ($div_Enb_node->tag ne "div") {return;}

    my $table_skill_nodes = &GetNode::GetNode_Tag_Attr("table", "class", "PD0", \$div_Enb_node);
    my $tr_nodes = &GetNode::GetNode_Tag("tr", \$$table_skill_nodes[0]);

    foreach my $tr_node (@$tr_nodes) {
        my ($skill_id, $gift_open) = (0, 0);
        
        my $td_nodes = &GetNode::GetNode_Tag("td", \$tr_node);

        if ($$td_nodes[0]->as_text !~ /\d/) { next;}

        my $gift_id = $self->{CommonDatas}{ProperName}->GetOrAddId($$td_nodes[3]->as_text);

        $gift_open = ($$td_nodes[3]->as_text ne "-") ? 1 : 0;
        my $gp = ($$td_nodes[4]->as_text ne "") ? $$td_nodes[4]->as_text : 0;

        $skill_id = $self->{CommonDatas}{SkillData}->GetOrAddId($gift_open, [$$td_nodes[1]->as_text, $embryo_id, $is_physics, $$td_nodes[0]->as_text, $$td_nodes[2]->as_text, $gift_id, $gp]);

        $self->{Datas}{Skill}->AddData(join(ConstData::SPLIT, ($self->{ResultNo}, $self->{GenerateNo}, $self->{ENo}, $order, $skill_id, $gift_open) ));

    }
    return;
}
#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
