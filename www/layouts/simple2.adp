  <!-- A simple 2-column thingy. -->

  <table border=0 width="100%">
    <tr>
      <td valign=top width="50%">
        <list name="element_ids_1">
          <include src="@element_src@" element_id="@element_ids_1:item@" action_string=@action_string@ theme_id=@theme_id@ region="1" portal_id=@portal_id@ return_url=@return_url@ hide_links_p=@hide_links_p@><br>
        </list>
      </td>
      <td valign=top width="50%">
        <list name="element_ids_2">
          <include src="@element_src@" element_id="@element_ids_2:item@" action_string=@action_string@ theme_id=@theme_id@ region="2" portal_id=@portal_id@ return_url=@return_url@ hide_links_p=@hide_links_p@><br>
        </list>
      </td>
    </tr>
    </table>
