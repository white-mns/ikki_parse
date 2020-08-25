#===================================================================
#        一揆用スクレイピング関数パッケージ
#-------------------------------------------------------------------
#            (C) 2020 @white_mns
#===================================================================

package GetIkkiNode;
use source::lib::GetNode;

#-----------------------------------#
#    対戦組み合わせTABLE取得
#------------------------------------
#    引数｜データノード
#          タイトル画像名
#-----------------------------------#
sub SearchTableNodeFromStarImg{
    my $nodes = shift;
    my $title_text   = shift;

    foreach my $node (@$nodes) {
        my $parent_table_node = $node->parent->parent->parent;
        
        if ($parent_table_node->as_text ne $title_text) {next;}

        my @parent_right_nodes = $parent_table_node->right;

        return $table_node = $parent_right_nodes[2];
    }

    return;
}


#-----------------------------------#
#    対戦組み合わせTABLE取得
#------------------------------------
#    引数｜データノード
#          タイトル画像名
#-----------------------------------#
sub SearchMatchingTableNodeFromStarImg{
    my $nodes = shift;
    my $title_text   = shift;

    my $table_node = &SearchTableNodeFromStarImg($nodes, $title_text);

    if (!$table_node) {return;}

    my $matching_nodes = &GetNode::GetNode_Tag_Attr("table", "width", "870", \$table_node);

    foreach $matching_node (@$matching_nodes) {
        my $u_B5i_nodes = &GetNode::GetNode_Tag_Attr("u", "class", "B5i", \$matching_node);

        if (scalar(@$u_B5i_nodes)) {return $matching_node;}
    }

    return;
}

#-----------------------------------#
#    リンクからENoを取得する
#------------------------------------
#    引数｜リンクノード
#-----------------------------------#
sub GetENoFromLink{
    my $node = shift;
    
    if (!$node || $node !~ /HASH/) {return 0;}

    my $url = $node->attr("href");

    if ($url =~ /k(\d+).html/) {
        return $1;
    }

    return 0;

}

1;
