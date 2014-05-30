# -*- coding: utf-8 -*-
import os, traceback, logging, datetime
import win32com.client
import pythoncom

from win32com.client import DispatchEx
from common import *

__all__ = ["getExcelVersion", "ExcelBasicGenerator", 'CABReport', 'CABItemReport', 'CABOrder']


XlBorderWeight = {
                  "xlHairline" : 1,
                  "xlThin" : 2,
                  "xlMedium" : 3,
                  "xlThick" : 4
                  }

XlBordersIndex = {
                  "xlDiagonalDown" : 5,
                  "xlDiagonalUp" : 6,
                  "xlEdgeBottom" : 9,
                  "xlEdgeLeft" : 7,
                  "xlEdgeRight" : 10,
                  "xlEdgeTop" : 8,
                  "xlInsideHorizontal" : 12,
                  "xlInsideVertical" : 11,
                  }



# http://msdn.microsoft.com/en-us/library/microsoft.office.interop.excel.xlhalign.aspx
XlHAlign = {
          "xlHAlignCenter" :-4108,  # Center
          "xlHAlignCenterAcrossSelection" : 7,  # Center across selection.
          "xlHAlignDistributed" :-4117,  # Distribute
          "xlHAlignFill" : 5,  # Fill
          "xlHAlignGeneral" : 1,  # Align according to data type.
          "xlHAlignJustify" :-4130,  # Justify
          "xlHAlignLeft" :-4130,  # Left
          "xlHAlignRight" :-4152,  # Right
          }


HorizontalAlignment = {
                       "xlCenter" :-4108,
                       "xlDistributed" :-4117,
                       "xlJustify" :-4130,
                       "xlLeft" :-4131,
                       "xlRight" :-4152,
                       }


XlUnderlineStyle = {
    "xlUnderlineStyleNone" :-4142,
    "xlUnderlineStyleSingle" : 2,
    "xlUnderlineStyleDouble" :-4119,
    "xlUnderlineStyleSingleAccounting" :4,
    "xlUnderlineStyleDoubleAccounting" : 5,
}


InteriorPattern = {
                   "xlSolid" : 1,
                   }


InteriorPatternColorIndex = {
                             "xlAutomatic" :-4105,
                             }

XlThemeColor = {
                "xlThemeColorAccent1" :    5,  # Accent1
                "xlThemeColorAccent2" :    6,  # Accent2
                "xlThemeColorAccent3" :    7,  # Accent3
                "xlThemeColorAccent4" :   8,  # Accent4
                "xlThemeColorAccent5" :   9,  # Accent5
                "xlThemeColorAccent6" :   10,  # Accent6
                "xlThemeColorDark1"   : 1,  # Dark1
                "xlThemeColorDark2"   : 3,  # Dark2
                "xlThemeColorFollowedHyperlink"  :  12,  # Followed hyperlink
                "xlThemeColorHyperlink" :    11,  # Hyperlink
                "xlThemeColorLight1"  :    2,  # Light1
                "xlThemeColorLight2"  : 4,  # Light2
                }


def getExcelVersion():
    pythoncom.CoInitialize()
    excelObj = DispatchEx( 'Excel.Application' )
    return {
            "9.0" : "2000",
            "10.0": "2002",
            "11.0": "2003",
            "12.0": "2007",
            "14.0": "2010",
            "15.0": "2013",
            }.get( excelObj.Version, '' )




class ExcelBasicGenerator:
    def __init__( self, templatePath = None, destinationPath = None, overwritten = True ):
        # solve the problem when create the excel at second time ,the exception is occur.
        pythoncom.CoInitialize()

        self.excelObj = DispatchEx( 'Excel.Application' )
        self.excelObj.Visible = False
        self.excelObj.DisplayAlerts = False

        if templatePath and os.path.exists( templatePath ):
            self.workBook = self.excelObj.Workbooks.open( templatePath )
        else:
            self.workBook = self.excelObj.Workbooks.Add()

        self.destinationPath = os.path.normpath( destinationPath ) if destinationPath else None
        self.overwritten = overwritten

    def inputData( self ): pass

    def outputData( self ):
        try:
            if not self.destinationPath : pass
            elif os.path.exists( self.destinationPath ):
                if self.overwritten:
                    os.remove( self.destinationPath )
                    self.excelObj.ActiveWorkbook.SaveAs( self.destinationPath )
            else:
                self.excelObj.ActiveWorkbook.SaveAs( self.destinationPath )
        except:
            traceback.print_exc()
        finally:
            try:
                self.workBook.Close( SaveChanges = 0 )
            except:
                traceback.print_exc()

    def clearData( self ):
        try:
            if hasattr( self, "workBook" ): self.workBook.Close( SaveChanges = 0 )
        except:
            traceback.print_exc()

    def _drawCellLine( self, sheet, sheet_range ):
        try:
            for line in ["xlEdgeBottom", "xlEdgeLeft", "xlEdgeRight", "xlEdgeTop"]:
                sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).Weight = XlBorderWeight["xlMedium"]
                sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).LineStyle = 1
            for line in ["xlInsideHorizontal", "xlInsideVertical"]:
                sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).Weight = XlBorderWeight["xlThin"]
                sheet.Range( sheet_range ).Borders( XlBordersIndex[line] ).LineStyle = 1
        except:
            pass




class CABReport( ExcelBasicGenerator ):
    def inputData( self, data = [] ):
        excelSheet = self.workBook.Sheets( 1 )
        if not data:
            data = [( "", ), ]
        startRow = 2
        row = len( data )
        col = len( data[0] )
        _range = "A%d:%s%d" % ( startRow, number2alphabet( col ), startRow + row - 1 )
        excelSheet.Range( _range ).Value = data
        self._drawCellLine( excelSheet, _range )
        excelSheet.Columns( "A:AZ" ).EntireColumn.AutoFit()



class CABItemReport( ExcelBasicGenerator ):
    def inputData( self, data = [] ):
        excelSheet = self.workBook.Sheets( 1 )
        if not data:
            data = [( "", ), ]
        startRow = 2
        row = len( data )
        col = len( data[0] )
        _range = "A%d:%s%d" % ( startRow, number2alphabet( col ), startRow + row - 1 )
        excelSheet.Range( _range ).Value = data
        self._drawCellLine( excelSheet, _range )
        excelSheet.Columns( "A:AZ" ).EntireColumn.AutoFit()



class CABOrder( ExcelBasicGenerator ):
    def inputData( self, data = [] ):
        mapping = {
                   'no' : 'B1', 'createTime' : 'F1',
                   'shipCompany' : 'F5', 'shipAttn' : 'F6', 'shipAddress' : 'F7', 'shipAddress2' : 'F8', 'shipAddress3' : 'F9',
                   'shipCity' : 'F10', 'shipState' : 'F11', 'shipZip' : 'F12', 'shipCountry' : 'F13', 'shipTel' : 'F14', 'shipFax' : 'F15',
                   'shipEmail' : 'F16', 'shipRemark' : 'F17',
                   'billCompany' : 'B5', 'billAttn' : 'B6', 'billAddress' : 'B7', 'billAddress2' : 'B8', 'billAddress3' : 'B9',
                   'billCity' : 'B10', 'billState' : 'B11', 'billZip' : 'B12', 'billCountry' : 'B13', 'billTel' : 'B14', 'billFax' : 'B15',
                   'billEmail' : 'B16', 'billRemark' : 'B17', 'shipInstructions' : 'F18',
                   'customerpo' : 'B23', 'vendorpo' : 'B24',
                   }

        excelSheet = self.workBook.Sheets( 1 )

        for k, v in mapping.items(): excelSheet.Range( v ).Value = data.get( k, '' ) or ''
        details = data['details']
        startrow = 29
        if details :
            _range = "A%s:%s%s" % ( startrow, number2alphabet( len( details[0] ) ), startrow + len( details ) - 1 )
            excelSheet.Range( _range ).Value = details
            excelSheet.Range( _range ).Font.Size = 9
            self._drawCellLine( excelSheet, _range )
