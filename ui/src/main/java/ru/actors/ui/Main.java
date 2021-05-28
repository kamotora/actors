package ru.actors.ui;

import com.ericsson.otp.erlang.OtpNode;
import io.appulse.encon.Nodes;
import io.appulse.encon.config.NodeConfig;
import lombok.extern.log4j.Log4j2;

import java.util.Arrays;

@Log4j2
public class Main {

    public static final String ADDRESS = "127.0.1.0";

    static boolean checkPings(OtpNode from) {
        return Arrays.stream(MyNode.values())
                .allMatch(node -> checkPing(from, node.getNode()));
    }

    public static boolean checkPing(OtpNode from, String to) {
        boolean isPing = from.ping(to, 10000);
        if (isPing)
            log.info("Node ping from {} to {} is {}", from.node(), to, "SUCCESS");
        else
            log.error("Node ping from {} to {} is {}", from.node(), to, "FAILED");
        return isPing;
    }

    public static void main(String[] args) throws Exception {
        System.setProperty("OtpConnection.trace", "0");
        OtpNode senderNode = new OtpNode("jNodeSend@" + ADDRESS);
        senderNode.setCookie("cookie");
        OtpNode receiveNode = new OtpNode("jNodeReceive@" + ADDRESS);
        receiveNode.setCookie("cookie");
        if (checkPings(senderNode)) {
            new CustomerForm(senderNode, receiveNode);
        }

    }
}
