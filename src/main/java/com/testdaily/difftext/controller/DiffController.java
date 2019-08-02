package com.testdaily.difftext.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * @author guangjiechen
 * @createDate 2019/8/1 18:12
 */
@Controller
public class DiffController {
    @RequestMapping("/index")
    public String index(ModelMap map) {
        map.addAttribute("name","https://github.com/Inverseli/");
        return "index";
    }
}
