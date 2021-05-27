package ru.actors.ui;

import com.ericsson.otp.erlang.*;
import lombok.SneakyThrows;
import lombok.extern.log4j.Log4j2;
import lombok.val;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static ru.actors.ui.Node.CUSTOMER;

@Log4j2
class MainTest {

    private OtpNode testNode;

    @BeforeEach
    @SneakyThrows
    public void allPings() {
        testNode = new OtpNode("testNode@127.0.1.0");
        assertTrue(Main.checkPings(testNode));
    }

    @AfterEach
    public void clean() {
        testNode.close();
    }

    @Test
    @SneakyThrows
    public void sendViaConnectionTest() {
        OtpSelf self = new OtpSelf("me");
        OtpPeer customer = new OtpPeer(CUSTOMER.getId());
        assertEquals(customer.node(), CUSTOMER.getId());
        OtpConnection connection = self.connect(customer);
        connection.send(customer.node(), new OtpErlangString("KEK"));
    }

    @Test
    @SneakyThrows
    public void sendViaMailboxTest() {
        val box = testNode.createMbox();
        box.send(CUSTOMER.getId(), msg());
    }

    private OtpErlangObject msg() {
        return new OtpErlangString("KEK");
    }
}