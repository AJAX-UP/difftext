package com.testdaily.difftext.controller;

import com.testdaily.difftext.util.DiffMatchPatch;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;

/**
* @description 听力文本对比的controller
* @author  mkdlp
* @date  2019/7/25 9:44
*/
@RequestMapping("/admin/textComparison")
@Controller
public class TextComparisonController {

    @RequestMapping(value="")
    public String index(){
        return "admin/textComparison/textComparison";
    }

    @RequestMapping(value = "/compariText",method = { RequestMethod.POST } )
    @ResponseBody
    public String compariText(HttpServletRequest request, String teacherText, String studentText){
        DiffMatchPatch diff=new DiffMatchPatch();
        String compareStr = diff.getHtmlDiffString(teacherText.trim().replaceAll(" +", " "),studentText.trim().replaceAll(" +", " "));
        return compareStr;
    }
}
