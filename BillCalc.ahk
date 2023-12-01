/*
 * =============================================================================================== *
 * @Author           : RaptorX <graptorx@gmail.com>
 * @Script Name      : AutoHotkey ToolKit (AHK-ToolKit)
 * @Script Version   : 0.0.0.1
 * @Homepage         : 
 *
 * @Creation Date    : May 03, 2016
 * @Modification Date: 
 *
 * @Description      :
 * -------------------
 *
 * -----------------------------------------------------------------------------------------------
 * @License          :       Copyright ©2016 RaptorX <GPLv3>
 *
 *    This program is free software: you can redistribute it and/or modify it under the terms of
 *    the GNU General Public License as published by the Free Software Foundation,
 *     either version 3 of  the  License,  or (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY  OF MERCHANTABILITY
 *    or FITNESS FOR A PARTICULAR  PURPOSE.  See  the GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License along with this program.
 *    If not, see <http://www.gnu.org/licenses/gpl-3.0.txt>
 * -----------------------------------------------------------------------------------------------
 *
 * =============================================================================================== *
 */
 
#SingleInstance Force
#include <v1\eval\eval.h>

bc_Bills = 2000|1000|500|200|100|50|25|10|5|1
bundleValue := { 2000:200000
                ,1000:100000
                ,500:50000
                ,200:20000
                ,100:10000
                ,50:5000
                ,25:1000
                ,10:400
                ,5:200
                ,1:25}

Gui BillCalc: New
Gui, Font, s18, Century Gothic

iniExist := FileExist("bills.ini") ? true : false
Loop, Parse, bc_Bills, |
{
    Gui, Add, Edit, x10 y+20 w75 center vBill%A_LoopField% gUpdate, % iniExist ? iniRead("bills.ini", "Bills", A_LoopField) : 0
    Gui, Add, Edit, x+10 yp w75 center vBundle%A_LoopField% gUpdate
                  , % iniExist ? iniRead("bills.ini", "Bundle", A_LoopField) : 0
    Gui, Add, Text, x+10 yp w75 right vBillValue%A_LoopField%, %A_LoopField%
    Gui, Add, Text, x+20 w100 border right vTotal%A_LoopField%, % iniExist ? RegexReplace(BillTotal(A_LoopField), "\.\d+") : 0
}


Gui Add, Text, 0x10 x0 y+20 w600

Gui, Font, s24 bold, Century Gothic
Gui, Add, Text, x10 yp+10 w365 right vGranTotal, % "Total: " (iniExist ? GrandTotal() : 0)
Gui, Add, Button, x-2 y+10 w389 -TabStop gSave, Guardar

Gui show, w385, Bill Calculator
return

Save: ;{
    Gui, BillCalc: Submit, NoHide

    if (!FileExist("bills.ini"))
        FileAppend, [Bills]`n[Bundle]`n, bills.ini
    
    Tooltip % "Total: " Clipboard := GrandTotal()
    
    Loop, Parse, bc_Bills, |
    {

        current_bill := "Bill" A_LoopField
        current_bundle := "Bundle" A_LoopField
        iniWrite(%current_bill%, "bills.ini", "Bills", A_LoopField)
        iniWrite(%current_bundle%, "bills.ini", "Bundle", A_LoopField)

    }
    
    Sleep, 1000
    Tooltip
    return
;}

Update: ;{
    Gui, BillCalc: Submit, NoHide
    
    current_bill := RegexReplace(A_GuiControl, "i)bill|bundle")
    t_current_bill := % "Total" current_bill
    
    if (!RegexMatch(%A_GuiControl%,"[0-9\+\-\/\*\.]"))
    {
        ;GuiControl,, %A_GuiControl%, % %t_current_bill% := 0
        Send, {Home}+{End}
    }
    
    GuiControl,, %t_current_bill%, % RegexReplace(BillTotal(current_bill), "\.\d+")
    GuiControl,, % "GranTotal", % "Total: " GrandTotal()
    return
;}

Exit:                ;{
BillCalcGuiClose:
    ExitApp
;}

iniRead(file="", section="", key="", def = 0)
{
    IniRead, var, %file%, %section%, %key%, %def%
    return var
}

iniWrite(value="", file="", section="", key = "")
{
    Try
    {

        IniWrite, %value%, %file%, %section%, %key%
    
    } catch e {
        
        Msgbox, There was a problem while saving the file.
        
    }
    return ErrorLevel
}

GrandTotal()
{
    global
    local total := current_billTotal := current_bundleTotal := current_billvalue := current_bundlevalue := ""
    
    Loop, Parse, bc_Bills, |
    {

        current_bill := "Bill" A_LoopField
        current_bundle := "Bundle" A_LoopField
        
        GuiControlGet, current_billvalue,, %current_bill%
        GuiControlGet, current_bundlevalue,, %current_bundle%
    
        current_billTotal := current_billvalue * A_LoopField
        current_bundleTotal := current_bundlevalue * bundleValue[A_LoopField]
        total += current_billTotal + current_bundleTotal
    }
    
    return total
}

BillTotal(bill)
{
    global
    local current_billTotal := current_bundleTotal := current_billvalue := current_bundlevalue := ""
    
    current_bill := "Bill" bill
    current_bundle := "Bundle" bill
    
    GuiControlGet, current_billvalue,, %current_bill%
    GuiControlGet, current_bundlevalue,, %current_bundle%
    
    current_billTotal := current_billvalue * bill
    current_bundleTotal := current_bundlevalue * bundleValue[bill]
        
    return current_billTotal + current_bundleTotal
}

evaluate(control) {
    global
    msgbox % control
    GuiControlGet, current_value,, %control%
    msgbox % current_value
    
}

#IfWinActive Bill Calculator
;{
    
Esc::
    KeyWait, Esc, D T.5

    if (ErrorLevel)
        msgbox true ;Send, 0{Home}+{End}
    else
    {
        sleep 1
    }
return

NumpadAdd::
NumpadSub::
NumpadDiv::
NumpadMult::
    key := (inStr(a_thishotkey, "Add", true) ? "+" 
        :   inStr(a_thishotkey, "Sub", true) ? "-" 
        :   inStr(a_thishotkey, "Div", true) ? "/" 
        :   inStr(a_thishotkey, "Mult", true) ? "*" : "")
        
    Send, {End}{%key%}
return

Tab::
NumpadEnter::
    ControlGetFocus, focusControl
    ControlGetText, exp, %focusControl%
    ControlSetText, %focusControl%, % eval(exp)
    
    Send {Tab}
return

+Tab::
+NumpadEnter::
    ControlGetFocus, focusControl
    ControlGetText, exp, %focusControl%
    ControlSetText, %focusControl%, % eval(exp)
    
    Send +{Tab}
return
;}
#IfWinActive

