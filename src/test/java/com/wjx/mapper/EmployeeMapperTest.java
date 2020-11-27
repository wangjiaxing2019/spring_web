package com.wjx.mapper;

import com.wjx.pojo.Employee;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.List;

@SpringBootTest
public class EmployeeMapperTest {
    @Autowired
    private EmployeeMapper mapper;

    @Test
    public void getEmployees(){
        List<Employee> list = mapper.getEmployees();
        for (Employee employee : list) {
            System.out.println(employee);
        }
    }
}
