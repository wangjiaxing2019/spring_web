package com.wjx.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@Controller
public class HelloController {

    @RequestMapping("hello")
    public String hello(Model model){
        model.addAttribute("message", "Hello World Thymeleaf");
        return "hello";
    }
}
