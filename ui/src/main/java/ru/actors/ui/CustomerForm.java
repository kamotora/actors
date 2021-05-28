package ru.actors.ui;

import com.ericsson.otp.erlang.*;
import lombok.SneakyThrows;
import lombok.extern.log4j.Log4j2;
import lombok.val;
import org.jetbrains.annotations.Nullable;

import javax.swing.*;
import java.awt.*;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Log4j2
public class CustomerForm extends JFrame {
    private final ScheduledExecutorService executor;
    private final OtpMbox receiverMbox;
    private final OtpErlangPid receiverPid;
    private JTextArea textArea1;
    private JButton sendButton;
    private JPanel panel;
    private JRadioButton TVRadioButton;
    private JRadioButton phoneRadioButton;
    private JRadioButton speakersRadioButton;
    private JRadioButton cardRadioButton;
    private JRadioButton bookRadioButton;
    private JRadioButton notebookRadioButton;
    private JPanel mainPanel;
    private OtpNode sender;
    private OtpMbox senderMbox;
    private List<JRadioButton> radios = Arrays.asList(TVRadioButton, phoneRadioButton, speakersRadioButton, cardRadioButton, bookRadioButton, notebookRadioButton);

    @Nullable
    private String getProduct() {
        val text = radios.stream()
                .filter(AbstractButton::isSelected)
                .findFirst()
                .map(JRadioButton::getText);
        if (text.isPresent())
            return text.get();
        else {
            textArea1.append("Выберите продукт");
            return null;
        }
    }

    @SneakyThrows
    public CustomerForm(OtpNode sender, OtpNode receiver) {
        executor = Executors.newSingleThreadScheduledExecutor();
        this.sender = sender;
        setContentPane(mainPanel);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setSize(new Dimension(600, 600));
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setVisible(true);
        senderMbox = sender.createMbox();
        this.receiverPid = receiver.createPid();
        this.receiverMbox = receiver.createMbox();
        executor.scheduleAtFixedRate(new ReceiveRunnable(receiverMbox, textArea1), 0, 1000, TimeUnit.MILLISECONDS);
        sendButton.addActionListener(actionEvent -> {
            val product = getProduct();
            if (product != null)
                sendMsg(MyNode.CUSTOMER, product);
        });
    }

    @SneakyThrows
    private void sendMsg(MyNode node, String text) {
        OtpErlangObject msg = new OtpErlangTuple(new OtpErlangObject[]{receiverMbox.self(), new OtpErlangString(text)});
        senderMbox.send(node.getId(), node.getNode(), msg);
        log.info("Message sended to {}: {}", node.getId(), msg);
    }
}
