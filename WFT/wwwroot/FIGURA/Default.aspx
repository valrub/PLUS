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
				margin: 0 0 0 20;
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
				padding: 0;
			}
			#content {
				padding: 30px;
			}
			.asd td, .asd th {
				padding: 5px 10px;
				font-size: 15px;
				font-weight: 400;
				box-shadow: inset 0 7px 7px rgba(0,0,0,.03);
				min-width: 18px;
				text-align: center;
			}
			.asd tr td:first-child {
				text-align: left;
			}
			th {
				font-weight: 700;
			}
			h3 {
				display: block;
				margin: 0 0 15px;
                height: 28px;
                text-align: left;
            }
			#btnRefreshData {
				font-size: 13px;
				padding: 5px 7px;
				background: #eeeeee;
				border: none;
                align-items: stretch;
			}
			#btnRefresh {
				font-size: 13px;
				padding: 5px 7px;
				background: #eeeeee;
				border: none;
                align-items: flex-end;
			}
            #btnRecalculate {
				font-size: 13px;
				padding: 5px 7px;
				background: #eeeeee;
				border: none;
			}
			#btnRecalculate:active {
				background: #e0e0e0;
			}
			#dpMonthYear {
				font-size: 14px;
				padding: 5px 7px;
				border: none;
				border-left: none;
				width: 100px;
                background: white;
                color: black;
			}
			#dpImage {
				position: relative;
				top: 3px;
				right: 29px;
			}
			#reportReview {
				display: none;
				background: #ffffff;
				border: 1px solid #0099cc;
				height: auto;
                max-height: 700px;
				right: 30px;
				position: fixed;
				top: 187px;
				width: 500px;
				box-shadow: 0 7px 13px rgba(0, 0, 0, .15);
			}
			#badReportReview {
				padding: 15px 15px 0;
				max-height: 556px;
				overflow-y: scroll;
			}
			#badReportReview p {
				font-size: 13px;
				margin: 0;
				padding-bottom: 15px;
				margin-bottom: 15px;
				border-bottom: 1px solid #0099cc;
				word-wrap: break-word;
			}
			#reportReview h3 {
				margin: 0;
				padding: 10px 15px;
				color: white;
				background: #0099cc;
			}
			#reportReview button {
				float: right;
				margin: 15px;
				font-size: 13px;
				padding: 7px 10px;
				background: #eeeeee;
				border: 1px solid #cccccc;
			}
			#Label_Total, #New_Total, #Missing_Total {
				font-weight: 700;
				background: #EFF3FB;
				border: none !important;
			}
			li {
				display: inline-block;
				padding: 10px 0;
			}
			li a {
				background: #aaa;
			    border-radius: 10px 10px 0 0;
			    border-right: 1px solid white;
			    color: #FFFFFF;
			    font-size: 13px;
			    padding: 10px;
			    text-decoration: none;
			    transition: all .15s linear;
			}
			li a.menu-active {
				background: #0099CC;
			}
			li a:hover {
				background: #0099CC;
				transition: all .15s linear;
			}
			p.FRSTitle {
				margin: 12.0pt 0in;
				text-align:center;
				line-height:115%;
				page-break-after:avoid;
				font-size:40.0pt;
				font-family:"Impact","sans-serif";
				color:navy;
				font-weight:bold;
			}
            .auto-style3 {
                font-weight: normal;
            }
            .auto-style9 {
                color: white; /* #CCFF33 */
                font-size: x-large;
            }
            #subheader {
                background: #ccc;
                padding: 10px 30px;
            }
            #subleft {
                display: inline-block;
				width: 100%;
            }
            #subright {
                float: right;
            }
            #subright select {
                padding: 5px 7px;
                border: none;
            }
            #subright label {
                font-size: 13px;
                padding: 6px 8px;
            }
			.InBetween {
				background-color: rgb(198, 239, 206);
				color: rgb(0, 97, 0) !important;
			}
            .MetricName {				
                text-decoration-color: ButtonText !important;             
                text-align: left !important;
			}
			.LessMinimum {
				background-color: rgb(255, 235, 156);
				color: rgb(156, 101, 0) !important;
			}
			.MoreMaximum {
				background-color: rgb(255, 199, 206);
				color: rgb(156, 0, 6) !important;
			}
			.MissingData {
				color: #ccc;
			}
			#cmbCustomers {
				width: auto;
				min-width: 150px;
			}
        	#btnRefresh0 {
				font-size: 13px;
				padding: 5px 7px;
				background: #eeeeee;
				border: none;
			}
			#btnPrint {
				font-size: 13px;
				padding: 5px 7px;
				background: #eeeeee;
				border: none;
                align-items: stretch;
				float: right;
				display: none;
			}
			</style>
    </head>
    <body>
        <form id="container" runat="server">
        <asp:Panel id="header" runat="server" style="text-align: right">
			<span class="auto-style9"><strong style="text-align: left">Focal Info Global Usage Reporting and Analysis</strong></span>
		    </asp:Panel>
            <div id="subheader">
                <div id="subleft" runat="server">
                    <asp:Button ID="btnRefresh" runat="server" Text="Display Results for:" OnClick="btnRefresh_Click" Font-Bold="True" BorderStyle="Inset" />
                    <asp:TextBox runat="server" type="text" id="dpMonthYear" value="" />
                    <img alt="Month/Year Picker" id="dpImage" onclick="showCalendarControl('dpMonthYear');" src="images/datepicker.gif" />
                    <asp:Button ID="btnRefreshData" runat="server" Text="RECALCULATE RESULTS" OnClick="btnRefreshData_Click"/>
					<img alt="" id="btnPrint" runat="server" onclick="javascript:window.print();" src="images/print.png" />
                </div>
                
            </div>
            <div id="content">
                <table cellpadding="0" cellspacing="0" border="0">
                    
                        <td class="auto-style3">
                            <h3>
                                <asp:Label ID="lblNoData" runat="server" Text="No results" Visible="false" ></asp:Label>
                            </h3>
                            <asp:GridView ID="dataMonthly" class="asd" runat="server" BorderStyle="Outset" CellPadding="4"  OnRowDataBound="ChangeRowColor" CellSpacing="1" ForeColor="#333333" GridLines="None" HorizontalAlign="Justify">
                                <AlternatingRowStyle BackColor="White" BorderStyle="Solid" />
                                <EditRowStyle BackColor="#2461BF" BorderStyle="Solid" />
                                <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                                <HeaderStyle BackColor="#0099cc" Font-Bold="True" ForeColor="White" />
                                <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                                <RowStyle BackColor="#EFF3FB" BorderStyle="Double" HorizontalAlign="Justify" VerticalAlign="Top" Wrap="False" />
                                <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                                <SortedAscendingCellStyle BackColor="#F5F7FB" />
                                <SortedAscendingHeaderStyle BackColor="#6D95E1" />
                                <SortedDescendingCellStyle BackColor="#E9EBEF" />
                                <SortedDescendingHeaderStyle BackColor="#4870BE" />
                            </asp:GridView>
                        </tr>
                </table>
                
			</div>
        </form>
		<div id="reportReview">
			<h3></h3>
			<div id="badReportReview">
				
			</div>
			<button>Close</button>
		</div>
		<script>
		    $("#dpMonthYear").keypress(function (e) {
		        e.preventDefault();
		    });
			$('td').click(function() {
				if (this.getAttribute('title')) {
					$('#reportReview table').hide();
					$('td[title]').css("border", "none");
					if ($(this).hasClass("DrillDown")) {
					    $('#badReportReview').empty();
					    var titleContent = this.getAttribute('title').substr(0, this.getAttribute('title').length - 3);
						console.log(titleContent);
					    var titleArray = titleContent.split(";");
					    for (i in titleArray) {
                            $('#badReportReview').append("<p>" + titleArray[i].replace("\n", "") + "</p>");
					    }
						var reportTitle = $(this).parent().children("td:first-of-type").text();
					    $('#reportReview h3').html(reportTitle);
						$('#reportReview').show();
						$('#badReportReview').show();
						
						console.log($('#badReportReview'));
						
					}
				}
			});
			$('#reportReview button').click(function() {
				$('#reportReview').hide();
				$('#reportReview table').hide();
				$('td[title]').css("border", "none");
			});
			if ($("table.asd").length) {
				$("#btnPrint").show();
			}
		</script>
    </body>
</html>

