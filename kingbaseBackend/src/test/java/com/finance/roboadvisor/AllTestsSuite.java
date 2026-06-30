package com.finance.roboadvisor;

import com.finance.roboadvisor.admin.service.impl.AdminServiceImplTest;
import com.finance.roboadvisor.auth.security.JwtAuthenticationFilterTest;
import com.finance.roboadvisor.auth.security.LoginUserTest;
import com.finance.roboadvisor.auth.security.SecurityConfigTest;
import com.finance.roboadvisor.auth.security.UserDetailsServiceImplTest;
import com.finance.roboadvisor.auth.service.impl.AuthServiceImplTest;
import com.finance.roboadvisor.common.api.ApiResultTest;
import com.finance.roboadvisor.common.exception.BusinessExceptionTest;
import com.finance.roboadvisor.common.exception.GlobalExceptionHandlerTest;
import com.finance.roboadvisor.common.util.JwtUtilTest;
import com.finance.roboadvisor.common.util.SecurityUtilTest;
import com.finance.roboadvisor.fund.service.impl.FundServiceImplTest;
import com.finance.roboadvisor.notification.service.impl.NotificationServiceImplTest;
import com.finance.roboadvisor.product.service.impl.*;
import com.finance.roboadvisor.publicapi.service.impl.PublicAdvisorProductServiceImplTest;
import com.finance.roboadvisor.review.service.impl.ReviewServiceImplTest;
import com.finance.roboadvisor.subscription.service.impl.SubscriptionServiceImplTest;
import com.finance.roboadvisor.transaction.service.impl.TransactionServiceImplTest;
import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.Suite;
import org.junit.platform.suite.api.SuiteDisplayName;

/**
 * 后端单元测试统一运行入口。
 * 在 IDE 中右键 → Run this Suite 即可执行所有测试。
 * 在命令行中：mvn test 同样会自动发现并运行所有测试。
 */
@Suite
@SuiteDisplayName("RoboAdvisor 后端全量单元测试")
@SelectClasses({
        // ===== 工具 / 公共类 =====
        ApiResultTest.class,
        JwtUtilTest.class,
        SecurityUtilTest.class,
        BusinessExceptionTest.class,
        GlobalExceptionHandlerTest.class,

        // ===== 认证 =====
        AuthServiceImplTest.class,
        UserDetailsServiceImplTest.class,
        JwtAuthenticationFilterTest.class,
        LoginUserTest.class,
        SecurityConfigTest.class,

        // ===== 业务 Service =====
        ProductServiceImplTest.class,
        WorkbenchServiceImplTest.class,
        ProductNavGenerationServiceImplTest.class,
        ProductHoldingSnapshotGenerationServiceImplTest.class,
        StrategyRuleValidationServiceImplTest.class,
        ReviewServiceImplTest.class,
        SubscriptionServiceImplTest.class,
        AdminServiceImplTest.class,

        // ===== 基金 / 公开 API =====
        FundServiceImplTest.class,
        PublicAdvisorProductServiceImplTest.class,

        // ===== 通知 / 交易 =====
        NotificationServiceImplTest.class,
        TransactionServiceImplTest.class
})
public class AllTestsSuite {
    // 此类的唯一作用是作为 @Suite 的载体，无需任何代码
}
