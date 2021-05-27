package ru.actors.ui;

import com.ericsson.otp.erlang.OtpNode;
import lombok.extern.log4j.Log4j2;

import java.util.Arrays;

@Log4j2
public class Main {

    public static final String ADDRESS = "127.0.1.0";

    private static boolean checkPings(OtpNode from) {
        return Arrays.stream(Node.values())
                .allMatch(node -> checkPing(from, node.getId()));
    }

    private static boolean checkPing(OtpNode from, String to) {
        boolean isPing = from.ping(to, 10000);
        if(isPing)
            log.info("Node ping from {} to {} is {}", from.node(), to, "SUCCESS");
        else
            log.error("Node ping from {} to {} is {}", from.node(), to, "FAILED");
        return isPing;
    }

    public static void main(String[] args) throws Exception {
        System.setProperty("OtpConnection.trace", "0");
        OtpNode javaNode = new OtpNode("jNodeSend@127.0.1.0");
        OtpNode receiveNode = new OtpNode("jNodeRecieve@127.0.1.0");
        if (checkPings(receiveNode) && checkPings(javaNode)) {
            new MainForm(javaNode, receiveNode);
        }

    }
}
