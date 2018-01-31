<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="WFT.Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
    <head runat="server">
    <title>WF Test Results</title>
    <link href="StyleCalender.css" rel="stylesheet" />
	<link href='http://fonts.googleapis.com/css?family=Open+Sans:400,300,700&subset=latin-ext,latin' rel='stylesheet' type='text/css'>
    <script type="text/javascript" language="javascript" src="js/CalendarControl.js"></script>
	<script type="text/javascript" language="javascript" src="js/jquery-2.1.1.min.js"></script>
        <style type="text/css">
			* {
				padding: 0;
				margin: 0;
				font-family: "Open Sans";
			}
            body {
				margin: 0;
			}
			#header {
				width: 100%;
				background: #0099cc url("./images/verint-logo.png") no-repeat 30px 15px;
				color: #ffffff;
				height: auto;
				padding: 20px 30px;
				box-shadow: 0 3px 21px rgba(0,0,170,.15);
				text-align: right;
				box-sizing: border-box;
				-moz-box-sizing: border-box;
				-webkit-box-sizing: border-box;
			}
			#header span {
				font-weight: 300;
				font-size: 16px;
			}
			#container {
				padding: 30px;
			}
			.asd td, .asd th {
				padding: 5px 10px;
				font-size: 15px;
				font-weight: 400;
				box-shadow: inset 0 7px 7px rgba(0,0,0,.03);
			}
			th {
				font-weight: 700;
			}
			h3 {
				display: block;
				margin: 15px 0;
			}
			#btnRefresh {
				font-size: 13px;
				padding: 5px 7px;
				background: #eeeeee;
				border: 1px solid #cccccc;
				cursor: pointer;
			}
			#btnRefresh:active {
				background: #e0e0e0;
			}
			#dpMonthYear {
				font-size: 14px;
				padding: 5px 7px;
				border: 1px solid #cccccc;
				border-left: none;
				width: 100px;
			}
			#dpImage {
				position: relative;
				top: 3px;
				right: 25px;
				cursor: pointer; 
			}
			td.imageReport, td.badReport { cursor: pointer; }
			
			
			
			#reportReview {
				display: none;
				background: #ffffff;
				border: 1px solid #0099cc;
				height: auto;
				left: 50%;
				left: 20%;
				margin-right: 20%;
				margin-top: -250px;
				position: fixed;
				top: 30%;
				width: inherit;
				box-shadow: 0 7px 13px rgba(0, 0, 0, .15);
			}
			
			
			
			#reportReview table {
				padding: 15px;
				border-spacing: 3px;
				display: none;
				width: 900px;
				font-size: x-small;
			}
			
			#reportReview td {
				border-bottom: 1px solid #0099cc;
			
				text-align: left;
				padding: 5px 10px;
			}
			#reportReview td:first-child {
				text-align: left;
				width: 10%;
			}
			#reportReview h3 {
				margin: 0;
				padding: 10px 15px;
				color: white;
				background: #4d4d4d;
			}
			#reportReview button {
				float: right;
				margin: 15px;
				font-size: 13px;
				padding: 7px 10px;
				background: #eeeeee;
				border: 1px solid #cccccc;
				cursor: pointer;
			}
			#Label_Total, #New_Total, #Missing_Total {
				font-weight: 700;
				background: #EFF3FB;
				border: none !important;
			}
			
			#reportReview th {
				border-bottom: 1px solid #0099cc;
				text-align: left;
				padding: 5px 10px;
				background: #eeeeee;
			}
			
			.lstMistakes td {
				width: 100px;
				font-size: xx-small;
			}
			
			.statistics.container {
				width: 100%;
				max-height: 700px;
				overflow-y: scroll;
			}
			
			.item_type {
				width: 15%;
				font-weight:bolder;
			}
			
			#totalRows {
			color:yellow;
			}
			
			#duration {
			color:yellow;
			}
			
			#tableName {
			color:yellow;
			}
			
			#exStatus {
			color:#80ffaa;
			}
			
			#CRName {
			color:#80ffaa;
			}
			
			#DT {
			color:#80ffaa;
			}
			
			#imageTableName {
			color:yellow;
			}
			
			#expectedRows {
			color:yellow;
			}
			
			#defected {
			color:yellow;
			}
			
			#msg {
			align:center;
			}
            .auto-style1 {
                width: 304px;
            }

            ._legend{
              float: right;
              margin-top: 5px;
            }

            ._legendFrame{
              border-style:solid;
              border-width: thin;
              color: grey;
              float: left;
            }

            ._legendElement{
              margin: 1px;
              float:left; 
              padding: 7px;

            }

            ._legendSign{
              padding: 5px;
              margin: 5px;
              float: left;
            }

            ._legendExplanation{
              float:right;
              padding:2px;
              margin: 2px;
              max-width: 170px;
              word-wrap:  word-break;
            }

        </style>
    </head>
    <body>
        <asp:Panel id="header" runat="server">
			<span>WEBINT 7 Web Flows - Daily test results  -- VERSION: 001.002.003 13/06/2017</span>
		    </asp:Panel>
        <form id="container" runat="server">
            <div style="text-align: left; border-top: 1px dashed #cccccc;">
                <div>
                    <p style="float:right"></p>
                    
                                 <span class='_legend'>
                                    <div class='_legendFrame'>
                                        <div class='_legendElement'>
                                          <span class='_legendSign' style='background:Bisque '>@</span>
                                          <p class='_legendExplanation'>Image</p>
                                        </div>
         
                                       <div class='_legendElement'>
                                          <span class='_legendSign' style='background:PaleGreen; color:PaleGreen'>' '</span>
                                          <p class='_legendExplanation'>The same number of records as in image</p>
                                        </div>
         
                                       <div class='_legendElement'>
                                          <span class='_legendSign' style='background:PaleGreen '>?</span>
                                          <p class='_legendExplanation'>Almost the same number of records as in image</p>
                                        </div>
         
                                       <div class='_legendElement'>
                                          <span class='_legendSign' style='background:DarkSalmon '>X</span>
                                          <p class='_legendExplanation'>Execution failed</p>
                                        </div>

                                        <div class='_legendElement'>
                                          <span class='_legendSign' style='background:DarkSalmon '>?</span>
                                          <p class='_legendExplanation'>Different number of records as in image</p>
                                        </div>
                                    </div>
                                  </span>
                    <table cellpadding="0" cellspacing="0" border="0">
		                <tr>
			                <td class="datepicker">
							    <h3>Pick a month</h3>
				                <asp:Button ID="btnRefresh" runat="server" Text="Display Results" OnClick="btnRefresh_Click" /><asp:TextBox runat="server" type="text" id="dpMonthYear" value="" /><img alt="Month/Year Picker" id="dpImage" onclick="showCalendarControl('dpMonthYear');" src="images/datepicker.gif" />
			                </td>
                            <td class="auto-style1">
							    <h3>Set CR name pattern</h3>
                                <asp:TextBox runat="server" type="text" id="CRPattern" value="%test%" width="200px" height="25px"/>
			                </td>
		                </tr>

                    </table>
                    <table>
                        <tr>
                            <td>
                                
                            </td>
                         
                        </tr>
                    </table>
                </div>
                <table cellpadding="0" cellspacing="0" border="0">
                    <td>
                        <asp:Panel ID="Panel3" runat="server"></asp:Panel>
                    </td>
                    <tr>
                        <td class="auto-style3">
                            <h3><asp:Label ID="lblNoData" runat="server" Text="No results" Visible="False" ></asp:Label></h3>
							<asp:GridView ID="dataMonthly" class="asd" runat="server" BorderStyle="Outset" CellPadding="4"  OnRowDataBound="ChangeRowColor" CellSpacing="1" ForeColor="#333333" GridLines="None">
								<AlternatingRowStyle BackColor="White" BorderStyle="Solid" />
								<EditRowStyle BackColor="#2461BF" BorderStyle="Solid" />
								<FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
								<HeaderStyle BackColor="#0099cc" Font-Bold="True" ForeColor="White" />
								<PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
								<RowStyle BackColor="#EFF3FB" />
								<SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
								<SortedAscendingCellStyle BackColor="#F5F7FB" />
								<SortedAscendingHeaderStyle BackColor="#6D95E1" />
								<SortedDescendingCellStyle BackColor="#E9EBEF" />
								<SortedDescendingHeaderStyle BackColor="#4870BE" />
							   
							</asp:GridView>         
                              
                        </td>
                        <td>
                                
                    </tr>
                </table>
                <asp:Panel ID="Panel4" runat="server" BackColor="#3399FF" ForeColor="#FFFF99" Width="1145px" BorderColor="#0066FF"></asp:Panel>
            </div>
        </form>
		<div id="reportReview" style="overflow:auto">
			<h3>
				<span>CR: </span><span id="CRName"></span>
				<span>DATE: </span><span id="DT"></span>
				<span>Status: </span><span id="exStatus"></span><br><br>
				<span>Table-Image: </span><span id="imageTableName"></span>
				<span>Qty-Expected:  </span><span style="width:auto" id="expectedRows"></span><br><br>
				<span>Table-Staging:  </span><span id="tableName"></span>
				<span>Qty-Collected:  </span><span id="totalRows"></span><br>
				<span>Duration </span><span id="duration"></span><br>
				<span>Defected Rows </span><span id="defected"></span>
			</h3>
			<div class="statistics container">
				<div class="statistics" id = "dynamic"></div>
				<br>
				<br>
				<div class="mistakes" id = "lstMistakes" style="overflow-y:scroll align:left">ERRORS JUST A SAMPLE</div>
				<br>
				<br>
				<div class="defects" id = "lstDefects" style="overflow-y:scroll align:left">DEFECTED JUST A SAMPLE</div>
			</div>
			<button>Close</button>
		</div>
		<script>
			$('td').click(function() {
				if (this.getAttribute('title')) {
					
					$('#reportReview').hide();
					
					$('td[title]').css("border", "none");
					$(this).css("border", "1px dashed white");
					
					var xml = this.getAttribute('title');
					xmlDoc = $.parseXML(xml);
					$xml = $(xmlDoc);
					
					$('#exStatus').html($xml.find("Report").attr("Status"));
					$('#CRName').html($xml.find("Report").attr("CR"));
					$('#DT').html($xml.find("Report").attr("DT"));
					$('#duration').html($xml.find("Report").attr("Duration"));
					$('#totalRows').html($xml.find("Report").attr("TotalRecords"));
					$('#tableName').html($xml.find("Report").attr("StagingTable"));
					$('#expectedRows').html($xml.find("Report").attr("ExpectedRecords"));
					$('#imageTableName').html($xml.find("Report").attr("ImageTable"));
					$('#defected').html($xml.find("DEFECTED").attr("Cnt"));
					
					if (this.getAttribute('class') == 'imageReport') {

						var dR = '<tr class="statistics"><th>ITEM TYPE</th><th>TYPE</th><th>Expected Qty</th></tr>';
						
						$xml.find("row").each(function(){
							dR = dR + '<tr><td>' + $(this).attr("ItemType") + '</td>';
							dR = dR+ '<td>' + $(this).attr("Type") + '</td>';
							dR = dR+ '<td>' + $(this).attr("Expected") + '</td></tr>';
						});
						
						$('#dynamic').html(dR);
						$('#reportReview').show();
						
						dR = '';
						drR = '';
						eR = '';
						
						
						//  ---------------------------- Errors --------------------------------
						var eR = '<tr align = "left"><th style="width:30px align:left">Event Code</th><th style="width:100px align:center class:msg">Event Message</th></tr>';
						$xml.find("err").each(function(){
							eR = eR + '<tr><td style="width:30px align:left">' + $(this).attr("ETypeName") + '</td>';
							eR = eR + '<td style="width:100px align:left">' + $(this).attr("ERROR_MESSAGE") + '</td></tr>';
						});
						
						$('#lstMistakes').html(eR);
						$('#lstMistakes').show();
						
						
						// ----- Defected Rows --------------------------------
						var drR = '<tr align = "left"><th style="width:30px align:left">Defect Description</th></tr>';
						
						
						$xml.find("defect").each(function(){
							
							drR = drR + '<td style="width:100px align:left">' + $(this).attr("DESCRIPTION") + '</td></tr>';
						});
						
						
						$('#lstDefects').html(drR);
						
					} 
					else if (this.getAttribute('class') == 'badReport')  {
						var pStatus = 'OK';
						if($xml.find("Report").attr("StatusCode") > -1)
						{
							pStatus = 'Error';
						}

						
						var dR = '<tr class="statistics"><th>ITEM TYPE</th><th>TYPE</th><th>Expected Qty</th><th>Actual Qty</th><th>Delta</th></tr>';
						
						$xml.find("row").each(function(){
							dR = dR + '<tr><td class="item_type">' + $(this).attr("ItemType") + '</td>';
							dR = dR+ '<td>' + $(this).attr("Type") + '</td>';
							dR = dR+ '<td>' + $(this).attr("Expected") + '</td>';
							dR = dR+ '<td>' + $(this).attr("Actual") + '</td>';
							dR = dR+ '<td>' + $(this).attr("Delta") + '</td></tr>';
						});
						
						$('#dynamic').html(dR);
						//dR = '';
						
						
						var eR = '<tr align = "left"><th style="width:30px align:left">Event Code</th><th style="width:100px align:center class:msg">Event Message</th></tr>';
						
						//  ---------------------------- Errors --------------------------------
						$xml.find("err").each(function(){
							eR = eR + '<tr><td style="width:30px align:left">' + $(this).attr("ETypeName") + '</td>';
							eR = eR + '<td style="width:100px align:left">' + $(this).attr("ERROR_MESSAGE") + '</td></tr>';
						});
						
						//----------------------------------------------------------------------

						$('#lstMistakes').html(eR);
						eR = '';
						
						// ----- Defected Rows --------------------------------
						var drR = '<tr align = "left"><th style="width:30px align:left">Defect Description</th></tr>';
						
						
						$xml.find("defect").each(function(){
							
							drR = drR + '<td style="width:100px align:left">' + $(this).attr("DESCRIPTION") + '</td></tr>';
						});
						
						
						$('#lstDefects').html(drR);
						drR = '';
						
						
						//----------------------------------------------------------------------

						
						
						$('#lstMistakes').show();
						$('#reportReview').show();
						$('#lstDefects').show();
						
					}
				}
			});
			
			$('#reportReview button').on('click',hideReports);
			$('body').on('keydown',function(e) {
				if (e.keyCode == 27) hideReports();
			});
			
			function hideReports() {
				$('#reportReview').hide();
				$('#reportReview table').hide();
				$('td[title]').css("border", "none");
			}
		</script>
    </body>
</html>

