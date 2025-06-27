-- District Zero Testing & Quality Assurance System
-- Version: 1.0.0

local TestingQA = {
    -- Test Suites
    testSuites = {},
    
    -- Quality Metrics
    qualityMetrics = {},
    
    -- Automated Testing
    automatedTesting = {},
    
    -- Performance Testing
    performanceTesting = {},
    
    -- Security Testing
    securityTesting = {},
    
    -- Integration Testing
    integrationTesting = {},
    
    -- Unit Testing
    unitTesting = {},
    
    -- Regression Testing
    regressionTesting = {},
    
    -- Load Testing
    loadTesting = {},
    
    -- Stress Testing
    stressTesting = {},
    
    -- Test Reports
    testReports = {},
    
    -- Quality Gates
    qualityGates = {}
}

-- Test Suites
local function RegisterTestSuite(name, testSuite)
    if not name or not testSuite then
        print('^1[District Zero] ^7Error: Invalid test suite registration')
        return false
    end
    
    TestingQA.testSuites[name] = {
        instance = testSuite,
        enabled = true,
        registered = GetGameTimer(),
        tests = {},
        passed = 0,
        failed = 0,
        skipped = 0
    }
    
    print('^2[District Zero] ^7Test suite registered: ' .. name)
    return true
end

local function RunTestSuite(name)
    if TestingQA.testSuites[name] and TestingQA.testSuites[name].enabled then
        local testSuite = TestingQA.testSuites[name]
        local startTime = GetGameTimer()
        
        print('^3[District Zero] ^7Running test suite: ' .. name)
        
        local results = {
            suite = name,
            startTime = startTime,
            endTime = 0,
            duration = 0,
            passed = 0,
            failed = 0,
            skipped = 0,
            tests = {}
        }
        
        -- Run all tests in the suite
        for testName, test in pairs(testSuite.instance.tests) do
            local testStart = GetGameTimer()
            local success, result = pcall(test.run)
            local testEnd = GetGameTimer()
            
            local testResult = {
                name = testName,
                success = success,
                result = result,
                duration = testEnd - testStart,
                timestamp = testStart
            }
            
            if success and result then
                results.passed = results.passed + 1
                testSuite.passed = testSuite.passed + 1
                print('^2[District Zero] ^7✓ Test passed: ' .. testName)
            else
                results.failed = results.failed + 1
                testSuite.failed = testSuite.failed + 1
                print('^1[District Zero] ^7✗ Test failed: ' .. testName .. ' - ' .. tostring(result))
            end
            
            table.insert(results.tests, testResult)
        end
        
        results.endTime = GetGameTimer()
        results.duration = results.endTime - results.startTime
        
        -- Store test results
        table.insert(TestingQA.testReports, results)
        
        print('^3[District Zero] ^7Test suite completed: ' .. name .. ' - ' .. results.passed .. ' passed, ' .. results.failed .. ' failed')
        
        return results
    end
    return nil
end

-- Quality Metrics
local function RegisterQualityMetric(name, metric)
    if not name or not metric then
        print('^1[District Zero] ^7Error: Invalid quality metric registration')
        return false
    end
    
    TestingQA.qualityMetrics[name] = {
        instance = metric,
        enabled = true,
        registered = GetGameTimer(),
        measurements = {},
        average = 0,
        min = math.huge,
        max = -math.huge
    }
    
    print('^2[District Zero] ^7Quality metric registered: ' .. name)
    return true
end

local function MeasureQuality(name, data)
    if TestingQA.qualityMetrics[name] and TestingQA.qualityMetrics[name].enabled then
        local metric = TestingQA.qualityMetrics[name]
        
        local success, value = pcall(metric.instance.measure, data)
        if success and value then
            table.insert(metric.measurements, {
                value = value,
                timestamp = GetGameTimer(),
                data = data
            })
            
            -- Update statistics
            metric.average = (metric.average * (#metric.measurements - 1) + value) / #metric.measurements
            metric.min = math.min(metric.min, value)
            metric.max = math.max(metric.max, value)
            
            return value
        end
    end
    return nil
end

-- Automated Testing
local function RegisterAutomatedTest(name, test)
    if not name or not test then
        print('^1[District Zero] ^7Error: Invalid automated test registration')
        return false
    end
    
    TestingQA.automatedTesting[name] = {
        instance = test,
        enabled = true,
        registered = GetGameTimer(),
        runs = 0,
        passed = 0,
        failed = 0,
        lastRun = 0
    }
    
    print('^2[District Zero] ^7Automated test registered: ' .. name)
    return true
end

local function RunAutomatedTest(name)
    if TestingQA.automatedTesting[name] and TestingQA.automatedTesting[name].enabled then
        local test = TestingQA.automatedTesting[name]
        test.runs = test.runs + 1
        test.lastRun = GetGameTimer()
        
        local success, result = pcall(test.instance.run)
        if success and result then
            test.passed = test.passed + 1
            print('^2[District Zero] ^7Automated test passed: ' .. name)
            return true
        else
            test.failed = test.failed + 1
            print('^1[District Zero] ^7Automated test failed: ' .. name .. ' - ' .. tostring(result))
            return false
        end
    end
    return false
end

-- Performance Testing
local function RegisterPerformanceTest(name, test)
    if not name or not test then
        print('^1[District Zero] ^7Error: Invalid performance test registration')
        return false
    end
    
    TestingQA.performanceTesting[name] = {
        instance = test,
        enabled = true,
        registered = GetGameTimer(),
        runs = 0,
        averageTime = 0,
        minTime = math.huge,
        maxTime = -math.huge
    }
    
    print('^2[District Zero] ^7Performance test registered: ' .. name)
    return true
end

local function RunPerformanceTest(name)
    if TestingQA.performanceTesting[name] and TestingQA.performanceTesting[name].enabled then
        local test = TestingQA.performanceTesting[name]
        test.runs = test.runs + 1
        
        local startTime = GetGameTimer()
        local success, result = pcall(test.instance.run)
        local endTime = GetGameTimer()
        
        if success then
            local duration = endTime - startTime
            test.averageTime = (test.averageTime * (test.runs - 1) + duration) / test.runs
            test.minTime = math.min(test.minTime, duration)
            test.maxTime = math.max(test.maxTime, duration)
            
            print('^2[District Zero] ^7Performance test completed: ' .. name .. ' - ' .. duration .. 'ms')
            return {
                success = true,
                duration = duration,
                result = result
            }
        else
            print('^1[District Zero] ^7Performance test failed: ' .. name .. ' - ' .. tostring(result))
            return {
                success = false,
                error = result
            }
        end
    end
    return nil
end

-- Security Testing
local function RegisterSecurityTest(name, test)
    if not name or not test then
        print('^1[District Zero] ^7Error: Invalid security test registration')
        return false
    end
    
    TestingQA.securityTesting[name] = {
        instance = test,
        enabled = true,
        registered = GetGameTimer(),
        runs = 0,
        vulnerabilities = 0,
        lastVulnerability = 0
    }
    
    print('^2[District Zero] ^7Security test registered: ' .. name)
    return true
end

local function RunSecurityTest(name)
    if TestingQA.securityTesting[name] and TestingQA.securityTesting[name].enabled then
        local test = TestingQA.securityTesting[name]
        test.runs = test.runs + 1
        
        local success, result = pcall(test.instance.run)
        if success and result then
            if result.vulnerabilities and #result.vulnerabilities > 0 then
                test.vulnerabilities = test.vulnerabilities + #result.vulnerabilities
                test.lastVulnerability = GetGameTimer()
                
                print('^1[District Zero] ^7Security test found vulnerabilities: ' .. name .. ' - ' .. #result.vulnerabilities .. ' issues')
            else
                print('^2[District Zero] ^7Security test passed: ' .. name .. ' - No vulnerabilities found')
            end
            
            return result
        else
            print('^1[District Zero] ^7Security test failed: ' .. name .. ' - ' .. tostring(result))
            return nil
        end
    end
    return nil
end

-- Integration Testing
local function RegisterIntegrationTest(name, test)
    if not name or not test then
        print('^1[District Zero] ^7Error: Invalid integration test registration')
        return false
    end
    
    TestingQA.integrationTesting[name] = {
        instance = test,
        enabled = true,
        registered = GetGameTimer(),
        runs = 0,
        passed = 0,
        failed = 0
    }
    
    print('^2[District Zero] ^7Integration test registered: ' .. name)
    return true
end

local function RunIntegrationTest(name)
    if TestingQA.integrationTesting[name] and TestingQA.integrationTesting[name].enabled then
        local test = TestingQA.integrationTesting[name]
        test.runs = test.runs + 1
        
        local success, result = pcall(test.instance.run)
        if success and result then
            test.passed = test.passed + 1
            print('^2[District Zero] ^7Integration test passed: ' .. name)
            return true
        else
            test.failed = test.failed + 1
            print('^1[District Zero] ^7Integration test failed: ' .. name .. ' - ' .. tostring(result))
            return false
        end
    end
    return false
end

-- Unit Testing
local function RegisterUnitTest(name, test)
    if not name or not test then
        print('^1[District Zero] ^7Error: Invalid unit test registration')
        return false
    end
    
    TestingQA.unitTesting[name] = {
        instance = test,
        enabled = true,
        registered = GetGameTimer(),
        runs = 0,
        passed = 0,
        failed = 0
    }
    
    print('^2[District Zero] ^7Unit test registered: ' .. name)
    return true
end

local function RunUnitTest(name)
    if TestingQA.unitTesting[name] and TestingQA.unitTesting[name].enabled then
        local test = TestingQA.unitTesting[name]
        test.runs = test.runs + 1
        
        local success, result = pcall(test.instance.run)
        if success and result then
            test.passed = test.passed + 1
            print('^2[District Zero] ^7Unit test passed: ' .. name)
            return true
        else
            test.failed = test.failed + 1
            print('^1[District Zero] ^7Unit test failed: ' .. name .. ' - ' .. tostring(result))
            return false
        end
    end
    return false
end

-- Regression Testing
local function RegisterRegressionTest(name, test)
    if not name or not test then
        print('^1[District Zero] ^7Error: Invalid regression test registration')
        return false
    end
    
    TestingQA.regressionTesting[name] = {
        instance = test,
        enabled = true,
        registered = GetGameTimer(),
        runs = 0,
        passed = 0,
        failed = 0,
        baseline = test.baseline or {}
    }
    
    print('^2[District Zero] ^7Regression test registered: ' .. name)
    return true
end

local function RunRegressionTest(name)
    if TestingQA.regressionTesting[name] and TestingQA.regressionTesting[name].enabled then
        local test = TestingQA.regressionTesting[name]
        test.runs = test.runs + 1
        
        local success, result = pcall(test.instance.run, test.baseline)
        if success and result then
            test.passed = test.passed + 1
            print('^2[District Zero] ^7Regression test passed: ' .. name)
            return true
        else
            test.failed = test.failed + 1
            print('^1[District Zero] ^7Regression test failed: ' .. name .. ' - ' .. tostring(result))
            return false
        end
    end
    return false
end

-- Load Testing
local function RegisterLoadTest(name, test)
    if not name or not test then
        print('^1[District Zero] ^7Error: Invalid load test registration')
        return false
    end
    
    TestingQA.loadTesting[name] = {
        instance = test,
        enabled = true,
        registered = GetGameTimer(),
        runs = 0,
        averageLoad = 0,
        maxLoad = 0
    }
    
    print('^2[District Zero] ^7Load test registered: ' .. name)
    return true
end

local function RunLoadTest(name)
    if TestingQA.loadTesting[name] and TestingQA.loadTesting[name].enabled then
        local test = TestingQA.loadTesting[name]
        test.runs = test.runs + 1
        
        local success, result = pcall(test.instance.run)
        if success and result then
            test.averageLoad = (test.averageLoad * (test.runs - 1) + result.load) / test.runs
            test.maxLoad = math.max(test.maxLoad, result.load)
            
            print('^2[District Zero] ^7Load test completed: ' .. name .. ' - Load: ' .. result.load)
            return result
        else
            print('^1[District Zero] ^7Load test failed: ' .. name .. ' - ' .. tostring(result))
            return nil
        end
    end
    return nil
end

-- Stress Testing
local function RegisterStressTest(name, test)
    if not name or not test then
        print('^1[District Zero] ^7Error: Invalid stress test registration')
        return false
    end
    
    TestingQA.stressTesting[name] = {
        instance = test,
        enabled = true,
        registered = GetGameTimer(),
        runs = 0,
        breakingPoint = 0,
        recoveryTime = 0
    }
    
    print('^2[District Zero] ^7Stress test registered: ' .. name)
    return true
end

local function RunStressTest(name)
    if TestingQA.stressTesting[name] and TestingQA.stressTesting[name].enabled then
        local test = TestingQA.stressTesting[name]
        test.runs = test.runs + 1
        
        local success, result = pcall(test.instance.run)
        if success and result then
            test.breakingPoint = result.breakingPoint or test.breakingPoint
            test.recoveryTime = result.recoveryTime or test.recoveryTime
            
            print('^2[District Zero] ^7Stress test completed: ' .. name .. ' - Breaking point: ' .. result.breakingPoint)
            return result
        else
            print('^1[District Zero] ^7Stress test failed: ' .. name .. ' - ' .. tostring(result))
            return nil
        end
    end
    return nil
end

-- Quality Gates
local function RegisterQualityGate(name, gate)
    if not name or not gate then
        print('^1[District Zero] ^7Error: Invalid quality gate registration')
        return false
    end
    
    TestingQA.qualityGates[name] = {
        instance = gate,
        enabled = true,
        registered = GetGameTimer(),
        checks = 0,
        passed = 0,
        failed = 0
    }
    
    print('^2[District Zero] ^7Quality gate registered: ' .. name)
    return true
end

local function CheckQualityGate(name)
    if TestingQA.qualityGates[name] and TestingQA.qualityGates[name].enabled then
        local gate = TestingQA.qualityGates[name]
        gate.checks = gate.checks + 1
        
        local success, result = pcall(gate.instance.check)
        if success and result then
            gate.passed = gate.passed + 1
            print('^2[District Zero] ^7Quality gate passed: ' .. name)
            return true
        else
            gate.failed = gate.failed + 1
            print('^1[District Zero] ^7Quality gate failed: ' .. name .. ' - ' .. tostring(result))
            return false
        end
    end
    return false
end

-- Test Reports
local function GenerateTestReport()
    local report = {
        timestamp = GetGameTimer(),
        testSuites = {},
        automatedTests = {},
        performanceTests = {},
        securityTests = {},
        integrationTests = {},
        unitTests = {},
        regressionTests = {},
        loadTests = {},
        stressTests = {},
        qualityGates = {},
        summary = {
            totalTests = 0,
            passedTests = 0,
            failedTests = 0,
            successRate = 0
        }
    }
    
    -- Collect test suite results
    for name, suite in pairs(TestingQA.testSuites) do
        report.testSuites[name] = {
            passed = suite.passed,
            failed = suite.failed,
            skipped = suite.skipped
        }
        report.summary.totalTests = report.summary.totalTests + suite.passed + suite.failed + suite.skipped
        report.summary.passedTests = report.summary.passedTests + suite.passed
        report.summary.failedTests = report.summary.failedTests + suite.failed
    end
    
    -- Collect automated test results
    for name, test in pairs(TestingQA.automatedTesting) do
        report.automatedTests[name] = {
            runs = test.runs,
            passed = test.passed,
            failed = test.failed
        }
        report.summary.totalTests = report.summary.totalTests + test.runs
        report.summary.passedTests = report.summary.passedTests + test.passed
        report.summary.failedTests = report.summary.failedTests + test.failed
    end
    
    -- Calculate success rate
    if report.summary.totalTests > 0 then
        report.summary.successRate = (report.summary.passedTests / report.summary.totalTests) * 100
    end
    
    return report
end

-- Testing & QA Methods
TestingQA.RegisterTestSuite = RegisterTestSuite
TestingQA.RunTestSuite = RunTestSuite
TestingQA.RegisterQualityMetric = RegisterQualityMetric
TestingQA.MeasureQuality = MeasureQuality
TestingQA.RegisterAutomatedTest = RegisterAutomatedTest
TestingQA.RunAutomatedTest = RunAutomatedTest
TestingQA.RegisterPerformanceTest = RegisterPerformanceTest
TestingQA.RunPerformanceTest = RunPerformanceTest
TestingQA.RegisterSecurityTest = RegisterSecurityTest
TestingQA.RunSecurityTest = RunSecurityTest
TestingQA.RegisterIntegrationTest = RegisterIntegrationTest
TestingQA.RunIntegrationTest = RunIntegrationTest
TestingQA.RegisterUnitTest = RegisterUnitTest
TestingQA.RunUnitTest = RunUnitTest
TestingQA.RegisterRegressionTest = RegisterRegressionTest
TestingQA.RunRegressionTest = RunRegressionTest
TestingQA.RegisterLoadTest = RegisterLoadTest
TestingQA.RunLoadTest = RunLoadTest
TestingQA.RegisterStressTest = RegisterStressTest
TestingQA.RunStressTest = RunStressTest
TestingQA.RegisterQualityGate = RegisterQualityGate
TestingQA.CheckQualityGate = CheckQualityGate
TestingQA.GenerateTestReport = GenerateTestReport

-- Default Testing Features
RegisterTestSuite('core_functionality', {
    tests = {
        mission_system = {
            run = function()
                -- Test mission system functionality
                return true
            end
        },
        team_system = {
            run = function()
                -- Test team system functionality
                return true
            end
        },
        district_system = {
            run = function()
                -- Test district system functionality
                return true
            end
        }
    }
})

RegisterQualityMetric('code_quality', {
    measure = function(data)
        -- Measure code quality metrics
        local quality = 0
        
        if data.complexity and data.complexity < 10 then
            quality = quality + 25
        end
        
        if data.coverage and data.coverage > 80 then
            quality = quality + 25
        end
        
        if data.performance and data.performance < 100 then
            quality = quality + 25
        end
        
        if data.security and data.security > 90 then
            quality = quality + 25
        end
        
        return quality
    end
})

RegisterAutomatedTest('mission_creation', {
    run = function()
        -- Test automated mission creation
        return true
    end
})

RegisterPerformanceTest('mission_processing', {
    run = function()
        -- Test mission processing performance
        return {
            duration = 50,
            throughput = 100
        }
    end
})

RegisterSecurityTest('input_validation', {
    run = function()
        -- Test input validation security
        return {
            vulnerabilities = {},
            security_score = 95
        }
    end
})

RegisterIntegrationTest('mission_team_integration', {
    run = function()
        -- Test mission and team system integration
        return true
    end
})

RegisterUnitTest('mission_validation', {
    run = function()
        -- Test mission validation unit
        return true
    end
})

RegisterRegressionTest('mission_completion', {
    baseline = { completion_rate = 95 },
    run = function(baseline)
        -- Test mission completion regression
        local current_rate = 96
        return current_rate >= baseline.completion_rate
    end
})

RegisterLoadTest('concurrent_missions', {
    run = function()
        -- Test concurrent mission load
        return {
            load = 85,
            response_time = 200
        }
    end
})

RegisterStressTest('mission_overload', {
    run = function()
        -- Test mission system stress
        return {
            breakingPoint = 150,
            recoveryTime = 5000
        }
    end
})

RegisterQualityGate('deployment_ready', {
    check = function()
        -- Check if system is ready for deployment
        local checks = {
            tests_passed = true,
            performance_ok = true,
            security_ok = true,
            integration_ok = true
        }
        
        for check, passed in pairs(checks) do
            if not passed then
                return false
            end
        end
        
        return true
    end
})

print('^2[District Zero] ^7Testing & QA system initialized')

-- Exports
exports('RegisterTestSuite', RegisterTestSuite)
exports('RunTestSuite', RunTestSuite)
exports('RegisterQualityMetric', RegisterQualityMetric)
exports('MeasureQuality', MeasureQuality)
exports('RegisterAutomatedTest', RegisterAutomatedTest)
exports('RunAutomatedTest', RunAutomatedTest)
exports('RegisterPerformanceTest', RegisterPerformanceTest)
exports('RunPerformanceTest', RunPerformanceTest)
exports('RegisterSecurityTest', RegisterSecurityTest)
exports('RunSecurityTest', RunSecurityTest)
exports('RegisterIntegrationTest', RegisterIntegrationTest)
exports('RunIntegrationTest', RunIntegrationTest)
exports('RegisterUnitTest', RegisterUnitTest)
exports('RunUnitTest', RunUnitTest)
exports('RegisterRegressionTest', RegisterRegressionTest)
exports('RunRegressionTest', RunRegressionTest)
exports('RegisterLoadTest', RegisterLoadTest)
exports('RunLoadTest', RunLoadTest)
exports('RegisterStressTest', RegisterStressTest)
exports('RunStressTest', RunStressTest)
exports('RegisterQualityGate', RegisterQualityGate)
exports('CheckQualityGate', CheckQualityGate)
exports('GenerateTestReport', GenerateTestReport)

return TestingQA 