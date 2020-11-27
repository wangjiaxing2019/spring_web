package com.wjx.controller;

import com.wjx.mapper.DepartmentMapper;
import com.wjx.mapper.EmployeeMapper;
import com.wjx.pojo.Department;
import com.wjx.pojo.Employee;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

import java.util.List;

@Controller
public class EmployeeController {
    @Autowired
    EmployeeMapper employeeMapper;
    @Autowired
    DepartmentMapper departmentMapper;

    @GetMapping("/emps")
    public String list(Model model){
        List<Employee> list = employeeMapper.getEmployees();
        model.addAttribute("emps", list);
        return "emp/list";
    }
    @GetMapping("/emp")
    public String toAddEmployee(Model model){
        List<Department> departments = departmentMapper.getDepartments();
        model.addAttribute("departments", departments);
        //return "redirect:/addEmployee.html";
        return "emp/add";
    }
    @PostMapping("/emp")
    public String addEmployee(Employee employee){
        employeeMapper.save(employee);
        return "redirect:/emps";
    }
    @GetMapping("/putemp/{id}")
    public String putEmployee(@PathVariable("id") int id){
        Employee employee = employeeMapper.get(id);

        return "index";
    }
}
