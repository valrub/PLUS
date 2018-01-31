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
			}
			#reportReview {
				display: none;
				background: #ffffff;
				border: 1px solid #0099cc;
				height: auto;
				left: 50%;
				margin-left: -250px;
				margin-top: -250px;
				position: fixed;
				top: 50%;
				width: 500px;
				box-shadow: 0 7px 13px rgba(0, 0, 0, .15);
			}
			#reportReview table {
				padding: 15px;
				border-spacing: 3px;
				display: none;
			}
			#reportReview td {
				border-bottom: 1px solid #0099cc;
				width: 25%;
				text-align: center;
				padding: 5px 10px;
			}
			#reportReview td:first-child {
				text-align: left;
				width: 50%;
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
        </style>
    </head>
    <body>
        <asp:Panel id="header" runat="server">
			<span>WEBINT Web Flows - Daily test results  -- VERSION: 6.1</span>
		    </asp:Panel>
        <form id="container" runat="server">
            <div style="text-align: left; border-top: 1px dashed #cccccc;">
                <table cellpadding="0" cellspacing="0" border="0">
		            <tr>
			            <td class="datepicker">
							<h3>Pick a month</h3>
				            <asp:Button ID="btnRefresh" runat="server" Text="Display Results" OnClick="btnRefresh_Click" /><asp:TextBox runat="server" type="text" id="dpMonthYear" value="" /><img alt="Month/Year Picker" id="dpImage" onclick="showCalendarControl('dpMonthYear');" src="images/datepicker.gif" />
			            </td>
		            </tr>
                </table>
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
		<div id="reportReview">
			<h3></h3>
			<table id="badReportReview" style="width: 100%;">
				<tr><th></th><th>New</th><th>Missing</th></tr>
				<tr><td>Web Entities</td><td id="New_Web_Entities"></td><td id="Missing_Web_Entities"></td></tr>
				<tr><td>Topics</td><td id="New_Topics"></td><td id="Missing_Topics"></td></tr>
				<tr><td>Comments</td><td id="New_Comments"></td><td id="Missing_Comments"></td></tr>
				<tr><td>Likes</td><td id="New_Likes"></td><td id="Missing_Likes"></td></tr>
				<tr><td>Albums</td><td id="New_Albums"></td><td id="Missing_Albums"></td></tr>
				<tr><td>Images</td><td id="New_Images"></td><td id="Missing_Images"></td></tr>
				<tr><td>Videos</td><td id="New_Videos"></td><td id="Missing_Videos"></td></tr>
				<tr><td>Addresses</td><td id="New_Addresses"></td><td id="Missing_Addresses"></td></tr>
				<tr><td>Dates</td><td id="New_Dates"></td><td id="Missing_Dates"></td></tr>
				<tr><td>Identifiers</td><td id="New_Identifiers"></td><td id="Missing_Identifiers"></td></tr>
				<tr><td id="Label_Total">Total</td><td id="New_Total"></td><td id="Missing_Total"></td></tr>
			</table>
			<table id="imageReportReview" style="width: 100%;">
				<tr><td>Web Entities</td><td id="Web_Entities"></td></tr>
				<tr><td>Topics</td><td id="Topics"></td></tr>
				<tr><td>Comments</td><td id="Comments"></td></tr>
				<tr><td>Likes</td><td id="Likes"></td></tr>
				<tr><td>Albums</td><td id="Albums"></td></tr>
				<tr><td>Images</td><td id="Images"></td></tr>
				<tr><td>Videos</td><td id="Videos"></td></tr>
				<tr><td>Addresses</td><td id="Addresses"></td></tr>
				<tr><td>Dates</td><td id="Dates"></td></tr>
				<tr><td>Identifiers</td><td id="Identifiers"></td></tr>
			</table>
			<button>Close</button>
		</div>
		<script>
			$('td').click(function() {
				if (this.getAttribute('title')) {
					$('#reportReview table').hide();
					$('td[title]').css("border", "none");
					$(this).css("border", "1px dashed white");
					var xml = this.getAttribute('title');
					xmlDoc = $.parseXML(xml);
					$xml = $(xmlDoc);
					if (this.getAttribute('class') == 'imageReport') {
						$('#reportReview h3').html("Image " + $xml.find("Image").attr("JobID") + "-" + $xml.find("Image").attr("AccountID"));
						$('#Web_Entities').html($xml.find("Web_Entities").text());
						$('#Topics').html($xml.find("Topics").text());
						$('#Comments').html($xml.find("Comments").text());
						$('#Likes').html($xml.find("Likes").text());
						$('#Albums').html($xml.find("Albums").text());
						$('#Images').html($xml.find("Images").text());
						$('#Videos').html($xml.find("Videos").text());
						$('#Addresses').html($xml.find("Addresses").text());
						$('#Dates').html($xml.find("Dates").text());
						$('#Identifiers').html($xml.find("Identifiers").text());
						$('#reportReview').show();
						$('#imageReportReview').show();
					} else if (this.getAttribute('class') == 'badReport') {
						var New_Total = parseInt($xml.find("New_Web_Entities").text()) + parseInt($xml.find("New_Topics").text()) + parseInt($xml.find("New_Albums").text()) + parseInt($xml.find("New_Comments").text()) + parseInt($xml.find("New_Images").text()) + parseInt($xml.find("New_Addresses").text()) + parseInt($xml.find("New_Dates").text()) + parseInt($xml.find("New_Identifiers").text());
						var Missing_Total = parseInt($xml.find("Missing_Web_Entities").text()) + parseInt($xml.find("Missing_Topics").text()) + parseInt($xml.find("Missing_Albums").text()) + parseInt($xml.find("Missing_Comments").text()) + parseInt($xml.find("Missing_Images").text()) + parseInt($xml.find("Missing_Addresses").text()) + parseInt($xml.find("Missing_Dates").text()) + parseInt($xml.find("Missing_Identifiers").text());
						$('#reportReview h3').html("Report " + $xml.find("Report").attr("JobID") + "-" + $xml.find("Report").attr("AccountID"));
						$('#New_Web_Entities').html($xml.find("New_Web_Entities").text());
						$('#Missing_Web_Entities').html($xml.find("Missing_Web_Entities").text());
						$('#New_Topics').html($xml.find("New_Topics").text());
						$('#Missing_Topics').html($xml.find("Missing_Topics").text());
						$('#New_Comments').html($xml.find("New_Comments").text());
						$('#Missing_Comments').html($xml.find("Missing_Comments").text());
						$('#New_Likes').html($xml.find("New_Likes").text());
						$('#Missing_Likes').html($xml.find("Missing_Likes").text());
						$('#New_Albums').html($xml.find("New_Albums").text());
						$('#Missing_Albums').html($xml.find("Missing_Albums").text());
						$('#New_Images').html($xml.find("New_Images").text());
						$('#Missing_Images').html($xml.find("Missing_Images").text());
						$('#New_Videos').html($xml.find("New_Videos").text());
						$('#Missing_Videos').html($xml.find("Missing_Videos").text());
						$('#New_Addresses').html($xml.find("New_Addresses").text());
						$('#Missing_Addresses').html($xml.find("Missing_Addresses").text());
						$('#New_Dates').html($xml.find("New_Dates").text());
						$('#Missing_Dates').html($xml.find("Missing_Dates").text());
						$('#New_Identifiers').html($xml.find("New_Identifiers").text());
						$('#Missing_Identifiers').html($xml.find("Missing_Identifiers").text());
						$('#New_Total').html(New_Total);
						$('#Missing_Total').html(Missing_Total);
						$('#reportReview').show();
						$('#badReportReview').show();
					}
				}
			});
			$('#reportReview button').click(function() {
				$('#reportReview').hide();
				$('#reportReview table').hide();
				$('td[title]').css("border", "none");
			});
		</script>
    </body>
</html>

