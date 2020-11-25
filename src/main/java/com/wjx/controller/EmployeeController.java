package com.wjx.controller;

import com.wjx.mapper.EmployeeMapper;
import com.wjx.pojo.Employee;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class EmployeeController {
    @Autowired
    EmployeeMapper mapper;

    @GetMapping("/emps")
    public String list(Model model){
        List<Employee> list = mapper.getEmployees();
        model.addAttribute("emps", list);
        return "emp/list";
    }
}
